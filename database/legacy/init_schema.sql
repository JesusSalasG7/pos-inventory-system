-- =============================================================================
--  init_schema.sql
--  Multi-branch POS & Inventory Management — PostgreSQL schema
-- -----------------------------------------------------------------------------
--  Design notes
--  * The global catalog (products) is separated from per-branch stock
--    (branch_inventory), so each physical store operates independently.
--  * branch_inventory.current_stock is maintained exclusively through the
--    inventory_movements ledger (append-only). A trigger applies every
--    movement to the stock and a CHECK prevents negative stock (no overselling).
--  * Selling a product (sale_details INSERT) automatically writes a SALE
--    movement for the branch of the sale.
--  * sales.total_usd / total_fiat and sale_details.subtotal_usd are
--    intentional *historical snapshots* (prices and rates change over time).
--    Their consistency is enforced by CHECKs and a deferred integrity trigger,
--    so the redundancy can never drift.
--  * The 'ALL' branch value is only meaningful for users.assigned_branch
--    (a user allowed to operate in every branch). Physical records (stock,
--    cash sessions, sales) must belong to a concrete branch.
--
--  Money: NUMERIC(14,2). Quantities: NUMERIC(12,3) (fractional LTS / KG).
--  Exchange rate: NUMERIC(14,4), expressed as VES per 1 USD.
--
--  The whole script runs in a single transaction: it either fully applies
--  or leaves the database untouched.
-- =============================================================================

BEGIN;

-- Password hashing helpers (crypt / gen_salt) used by the application & seed.
CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- =============================================================================
-- 1. ENUM TYPES
-- =============================================================================

CREATE TYPE role AS ENUM ('MANAGER', 'SUPERVISOR');

CREATE TYPE branch AS ENUM ('VILLA_LIBERTAD', 'LAS_AMERICAS', 'ALL');

CREATE TYPE category AS ENUM (
    'LIQUIDS',
    'POWDERS',
    'ACCESSORIES',
    'DISINFECTANTS',
    'PAPER_GOODS',
    'PERSONAL_CARE',
    'PACKAGING',
    'OTHER'
);

CREATE TYPE unit_measure AS ENUM ('LTS', 'KG', 'UNITS');

CREATE TYPE inventory_movement_type AS ENUM ('INBOUND', 'SALE', 'SHRINKAGE', 'ADJUSTMENT');

CREATE TYPE payment_method AS ENUM ('POS_TERMINAL', 'CASH_FIAT', 'CASH_USD', 'MOBILE_PAYMENT');

CREATE TYPE currency AS ENUM ('VES', 'USD');


-- =============================================================================
-- 2. TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- users: system operators. assigned_branch = 'ALL' grants access to every branch.
-- -----------------------------------------------------------------------------
CREATE TABLE users (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    password_hash    TEXT         NOT NULL,
    role             role         NOT NULL,
    assigned_branch  branch       NOT NULL,

    CONSTRAINT users_name_not_blank       CHECK (btrim(name) <> ''),
    -- Guard against storing plain-text passwords: bcrypt/argon2 hashes are long.
    CONSTRAINT users_password_hash_length CHECK (length(password_hash) >= 50)
);

-- Login names are unique regardless of letter case.
CREATE UNIQUE INDEX users_name_unique_ci ON users (lower(name));

COMMENT ON TABLE  users IS 'System operators (managers / supervisors).';
COMMENT ON COLUMN users.assigned_branch IS 'Branch the user may operate in; ALL = every branch.';


-- -----------------------------------------------------------------------------
-- exchange_rates: history of the official VES/USD rate. The current rate is
-- the row with the most recent updated_at.
-- -----------------------------------------------------------------------------
CREATE TABLE exchange_rates (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usd_rate    NUMERIC(14,4) NOT NULL,
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT exchange_rates_usd_rate_positive CHECK (usd_rate > 0),
    CONSTRAINT exchange_rates_updated_at_unique UNIQUE (updated_at)
);

COMMENT ON COLUMN exchange_rates.usd_rate IS 'Amount of VES equivalent to 1 USD.';


-- -----------------------------------------------------------------------------
-- products: global catalog shared by all branches. Products are never deleted
-- once used; they are deactivated through is_active.
-- -----------------------------------------------------------------------------
CREATE TABLE products (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name            VARCHAR(150)  NOT NULL,
    category        category      NOT NULL,
    unit_measure    unit_measure  NOT NULL,
    cost_price_usd  NUMERIC(14,2) NOT NULL,
    sale_price_usd  NUMERIC(14,2) NOT NULL,
    is_active       BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT products_name_not_blank         CHECK (btrim(name) <> ''),
    CONSTRAINT products_cost_price_non_negative CHECK (cost_price_usd >= 0),
    CONSTRAINT products_sale_price_non_negative CHECK (sale_price_usd >= 0)
);

CREATE UNIQUE INDEX products_name_unique_ci ON products (lower(name));
CREATE INDEX        products_category_idx   ON products (category) WHERE is_active;


-- -----------------------------------------------------------------------------
-- branch_inventory: stock of a catalog product at one physical branch.
-- current_stock is written ONLY by the inventory_movements trigger.
-- -----------------------------------------------------------------------------
CREATE TABLE branch_inventory (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id     BIGINT        NOT NULL
                   REFERENCES products (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    branch         branch        NOT NULL,
    current_stock  NUMERIC(12,3) NOT NULL DEFAULT 0,
    minimum_stock  NUMERIC(12,3) NOT NULL DEFAULT 0,

    CONSTRAINT branch_inventory_branch_is_physical    CHECK (branch <> 'ALL'),
    CONSTRAINT branch_inventory_stock_non_negative    CHECK (current_stock >= 0),
    CONSTRAINT branch_inventory_minimum_non_negative  CHECK (minimum_stock >= 0),
    -- One stock record per product per branch.
    CONSTRAINT branch_inventory_product_branch_unique UNIQUE (product_id, branch)
);

CREATE INDEX branch_inventory_branch_idx ON branch_inventory (branch);


-- -----------------------------------------------------------------------------
-- inventory_movements: append-only stock ledger.
-- affected_quantity is SIGNED: positive adds stock, negative removes it.
--   INBOUND    -> must be > 0
--   SALE       -> must be < 0
--   SHRINKAGE  -> must be < 0
--   ADJUSTMENT -> any non-zero value (physical count corrections)
-- -----------------------------------------------------------------------------
CREATE TABLE inventory_movements (
    id                   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id              BIGINT                  NOT NULL
                         REFERENCES users (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    branch_inventory_id  BIGINT                  NOT NULL
                         REFERENCES branch_inventory (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    movement_type        inventory_movement_type NOT NULL,
    affected_quantity    NUMERIC(12,3)           NOT NULL,
    created_at           TIMESTAMPTZ             NOT NULL DEFAULT now(),

    CONSTRAINT inventory_movements_quantity_sign CHECK (
        CASE movement_type
            WHEN 'INBOUND'    THEN affected_quantity > 0
            WHEN 'SALE'       THEN affected_quantity < 0
            WHEN 'SHRINKAGE'  THEN affected_quantity < 0
            WHEN 'ADJUSTMENT' THEN affected_quantity <> 0
        END
    )
);

CREATE INDEX inventory_movements_inventory_date_idx
    ON inventory_movements (branch_inventory_id, created_at DESC);
CREATE INDEX inventory_movements_user_idx ON inventory_movements (user_id);


-- -----------------------------------------------------------------------------
-- cash_sessions: a cash-register shift (open -> close) at a branch.
-- -----------------------------------------------------------------------------
CREATE TABLE cash_sessions (
    id                 BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id            BIGINT        NOT NULL
                       REFERENCES users (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    branch             branch        NOT NULL,
    opened_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    closed_at          TIMESTAMPTZ,
    initial_cash_fund  NUMERIC(14,2) NOT NULL DEFAULT 0,

    CONSTRAINT cash_sessions_branch_is_physical   CHECK (branch <> 'ALL'),
    CONSTRAINT cash_sessions_fund_non_negative    CHECK (initial_cash_fund >= 0),
    CONSTRAINT cash_sessions_close_after_open     CHECK (closed_at IS NULL OR closed_at >= opened_at),
    -- Target for the composite FK in sales: guarantees sale.branch = session.branch.
    CONSTRAINT cash_sessions_id_branch_unique     UNIQUE (id, branch)
);

-- A user can have at most one open (not yet closed) session at a time.
CREATE UNIQUE INDEX cash_sessions_one_open_per_user
    ON cash_sessions (user_id) WHERE closed_at IS NULL;
CREATE INDEX cash_sessions_branch_opened_idx ON cash_sessions (branch, opened_at DESC);


-- -----------------------------------------------------------------------------
-- cash_expenses: petty-cash outflows recorded during a session.
-- Part of the session's lifecycle, so they are removed with it.
-- -----------------------------------------------------------------------------
CREATE TABLE cash_expenses (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cash_session_id  BIGINT        NOT NULL
                     REFERENCES cash_sessions (id) ON UPDATE CASCADE ON DELETE CASCADE,
    expense_reason   VARCHAR(255)  NOT NULL,
    amount           NUMERIC(14,2) NOT NULL,
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT cash_expenses_reason_not_blank CHECK (btrim(expense_reason) <> ''),
    CONSTRAINT cash_expenses_amount_positive  CHECK (amount > 0)
);

CREATE INDEX cash_expenses_session_idx ON cash_expenses (cash_session_id);


-- -----------------------------------------------------------------------------
-- sales: sale header. Totals and the applied rate are frozen at sale time.
-- -----------------------------------------------------------------------------
CREATE TABLE sales (
    id                     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id                BIGINT        NOT NULL
                           REFERENCES users (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    cash_session_id        BIGINT        NOT NULL,
    branch                 branch        NOT NULL,
    customer_id_document   VARCHAR(20),
    customer_name          VARCHAR(150),
    exchange_rate_applied  NUMERIC(14,4) NOT NULL,
    total_usd              NUMERIC(14,2) NOT NULL,
    total_fiat             NUMERIC(14,2) NOT NULL,
    created_at             TIMESTAMPTZ   NOT NULL DEFAULT now(),

    -- Composite FK: the sale must happen in the same branch as its cash session.
    CONSTRAINT sales_cash_session_fk
        FOREIGN KEY (cash_session_id, branch)
        REFERENCES cash_sessions (id, branch) ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT sales_branch_is_physical        CHECK (branch <> 'ALL'),
    CONSTRAINT sales_exchange_rate_positive    CHECK (exchange_rate_applied > 0),
    CONSTRAINT sales_total_usd_non_negative    CHECK (total_usd >= 0),
    CONSTRAINT sales_total_fiat_non_negative   CHECK (total_fiat >= 0),
    -- total_fiat is always the USD total converted at the applied rate.
    CONSTRAINT sales_total_fiat_matches_rate   CHECK (total_fiat = round(total_usd * exchange_rate_applied, 2)),
    CONSTRAINT sales_customer_doc_not_blank    CHECK (customer_id_document IS NULL OR btrim(customer_id_document) <> ''),
    CONSTRAINT sales_customer_name_not_blank   CHECK (customer_name IS NULL OR btrim(customer_name) <> '')
);

CREATE INDEX sales_branch_created_idx  ON sales (branch, created_at DESC);
CREATE INDEX sales_cash_session_idx    ON sales (cash_session_id);
CREATE INDEX sales_user_idx            ON sales (user_id);
CREATE INDEX sales_customer_doc_idx    ON sales (customer_id_document) WHERE customer_id_document IS NOT NULL;


-- -----------------------------------------------------------------------------
-- sale_details: line items. Deleted with their sale (CASCADE), but a product
-- that appears in any sale can never be deleted (RESTRICT).
-- -----------------------------------------------------------------------------
CREATE TABLE sale_details (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id         BIGINT        NOT NULL
                    REFERENCES sales (id) ON UPDATE CASCADE ON DELETE CASCADE,
    product_id      BIGINT        NOT NULL
                    REFERENCES products (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    quantity        NUMERIC(12,3) NOT NULL,
    unit_price_usd  NUMERIC(14,2) NOT NULL,
    subtotal_usd    NUMERIC(14,2) NOT NULL,

    CONSTRAINT sale_details_quantity_positive      CHECK (quantity > 0),
    CONSTRAINT sale_details_unit_price_non_negative CHECK (unit_price_usd >= 0),
    CONSTRAINT sale_details_subtotal_matches        CHECK (subtotal_usd = round(quantity * unit_price_usd, 2)),
    -- A product appears at most once per sale (quantities are aggregated).
    CONSTRAINT sale_details_sale_product_unique     UNIQUE (sale_id, product_id)
);

CREATE INDEX sale_details_product_idx ON sale_details (product_id);


-- -----------------------------------------------------------------------------
-- sale_payments: one sale may be paid with several methods/currencies.
-- Cash in USD must be USD; every other method settles in VES.
-- -----------------------------------------------------------------------------
CREATE TABLE sale_payments (
    id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id             BIGINT         NOT NULL
                        REFERENCES sales (id) ON UPDATE CASCADE ON DELETE CASCADE,
    payment_method      payment_method NOT NULL,
    currency            currency       NOT NULL,
    amount_paid         NUMERIC(14,2)  NOT NULL,
    approval_reference  VARCHAR(50),

    CONSTRAINT sale_payments_amount_positive CHECK (amount_paid > 0),
    CONSTRAINT sale_payments_method_currency CHECK (
        (payment_method =  'CASH_USD' AND currency = 'USD') OR
        (payment_method <> 'CASH_USD' AND currency = 'VES')
    ),
    -- Electronic payments must carry the bank/terminal approval reference.
    CONSTRAINT sale_payments_reference_required CHECK (
        payment_method NOT IN ('POS_TERMINAL', 'MOBILE_PAYMENT')
        OR (approval_reference IS NOT NULL AND btrim(approval_reference) <> '')
    )
);

CREATE INDEX sale_payments_sale_idx ON sale_payments (sale_id);


-- =============================================================================
-- 3. BUSINESS-RULE TRIGGERS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.1 A user may only act on a branch they are assigned to (or 'ALL').
-- -----------------------------------------------------------------------------
CREATE FUNCTION assert_user_branch_access(p_user_id BIGINT, p_branch branch)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_assigned branch;
BEGIN
    SELECT assigned_branch INTO v_assigned FROM users WHERE id = p_user_id;

    -- A missing user is reported by the foreign key itself.
    IF FOUND AND v_assigned <> 'ALL' AND v_assigned <> p_branch THEN
        RAISE EXCEPTION 'User % (branch %) cannot operate in branch %',
                        p_user_id, v_assigned, p_branch
              USING ERRCODE = 'check_violation';
    END IF;
END;
$$;

CREATE FUNCTION trg_check_user_branch_access()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM assert_user_branch_access(NEW.user_id, NEW.branch);
    RETURN NEW;
END;
$$;

CREATE TRIGGER cash_sessions_user_branch_access
    BEFORE INSERT OR UPDATE OF user_id, branch ON cash_sessions
    FOR EACH ROW EXECUTE FUNCTION trg_check_user_branch_access();

CREATE TRIGGER sales_user_branch_access
    BEFORE INSERT OR UPDATE OF user_id, branch ON sales
    FOR EACH ROW EXECUTE FUNCTION trg_check_user_branch_access();


-- -----------------------------------------------------------------------------
-- 3.2 Sales can only be registered in a cash session that is still open.
-- -----------------------------------------------------------------------------
CREATE FUNCTION trg_sales_require_open_session()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM cash_sessions
               WHERE id = NEW.cash_session_id AND closed_at IS NOT NULL) THEN
        RAISE EXCEPTION 'Cash session % is closed; sales cannot be registered',
                        NEW.cash_session_id
              USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER sales_require_open_session
    BEFORE INSERT ON sales
    FOR EACH ROW EXECUTE FUNCTION trg_sales_require_open_session();


-- -----------------------------------------------------------------------------
-- 3.3 Inventory ledger: every movement is applied to branch_inventory.
--     The current_stock >= 0 CHECK aborts any movement that would oversell.
--     The user must have access to the inventory's branch.
-- -----------------------------------------------------------------------------
CREATE FUNCTION trg_apply_inventory_movement()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_branch branch;
BEGIN
    UPDATE branch_inventory
       SET current_stock = current_stock + NEW.affected_quantity
     WHERE id = NEW.branch_inventory_id
    RETURNING branch INTO v_branch;

    IF FOUND THEN
        PERFORM assert_user_branch_access(NEW.user_id, v_branch);
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER inventory_movements_apply
    BEFORE INSERT ON inventory_movements
    FOR EACH ROW EXECUTE FUNCTION trg_apply_inventory_movement();


-- The ledger is immutable: mistakes are fixed with a new ADJUSTMENT movement.
CREATE FUNCTION trg_inventory_movements_immutable()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'inventory_movements is append-only; register an ADJUSTMENT instead'
          USING ERRCODE = 'restrict_violation';
END;
$$;

CREATE TRIGGER inventory_movements_no_update_delete
    BEFORE UPDATE OR DELETE ON inventory_movements
    FOR EACH ROW EXECUTE FUNCTION trg_inventory_movements_immutable();


-- -----------------------------------------------------------------------------
-- 3.4 Each sale line automatically discounts stock in the sale's branch by
--     writing a SALE movement to the ledger.
-- -----------------------------------------------------------------------------
CREATE FUNCTION trg_sale_detail_register_movement()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_id       BIGINT;
    v_branch        branch;
    v_inventory_id  BIGINT;
BEGIN
    SELECT user_id, branch INTO v_user_id, v_branch
      FROM sales WHERE id = NEW.sale_id;

    SELECT bi.id INTO v_inventory_id
      FROM branch_inventory bi
     WHERE bi.product_id = NEW.product_id
       AND bi.branch     = v_branch;

    IF v_inventory_id IS NULL THEN
        RAISE EXCEPTION 'Product % is not stocked in branch %', NEW.product_id, v_branch
              USING ERRCODE = 'foreign_key_violation';
    END IF;

    INSERT INTO inventory_movements (user_id, branch_inventory_id, movement_type, affected_quantity)
    VALUES (v_user_id, v_inventory_id, 'SALE', -NEW.quantity);

    RETURN NEW;
END;
$$;

CREATE TRIGGER sale_details_register_movement
    AFTER INSERT ON sale_details
    FOR EACH ROW EXECUTE FUNCTION trg_sale_detail_register_movement();


-- Sale lines are final; changing them would desynchronise the stock ledger.
CREATE FUNCTION trg_sale_details_immutable()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'sale_details cannot be modified; void the sale and register a new one'
          USING ERRCODE = 'restrict_violation';
END;
$$;

CREATE TRIGGER sale_details_no_update
    BEFORE UPDATE ON sale_details
    FOR EACH ROW EXECUTE FUNCTION trg_sale_details_immutable();


-- -----------------------------------------------------------------------------
-- 3.5 Sale integrity (checked at COMMIT, so header, lines and payments can be
--     inserted in any order inside one transaction):
--       * the sale has at least one line,
--       * total_usd equals the sum of the line subtotals,
--       * payments (converted to VES at the applied rate) cover total_fiat.
--         Overpayment is allowed (change is given back in cash).
-- -----------------------------------------------------------------------------
CREATE FUNCTION check_sale_integrity(p_sale_id BIGINT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_sale        sales%ROWTYPE;
    v_lines       INTEGER;
    v_lines_usd   NUMERIC;
    v_paid_fiat   NUMERIC;
BEGIN
    SELECT * INTO v_sale FROM sales WHERE id = p_sale_id;
    IF NOT FOUND THEN
        RETURN;  -- the sale was deleted (children removed by CASCADE)
    END IF;

    SELECT count(*), coalesce(sum(subtotal_usd), 0)
      INTO v_lines, v_lines_usd
      FROM sale_details WHERE sale_id = p_sale_id;

    IF v_lines = 0 THEN
        RAISE EXCEPTION 'Sale % has no line items', p_sale_id
              USING ERRCODE = 'check_violation';
    END IF;

    IF v_lines_usd <> v_sale.total_usd THEN
        RAISE EXCEPTION 'Sale % total_usd (%) does not match the sum of its lines (%)',
                        p_sale_id, v_sale.total_usd, v_lines_usd
              USING ERRCODE = 'check_violation';
    END IF;

    SELECT coalesce(sum(CASE currency
                            WHEN 'USD' THEN round(amount_paid * v_sale.exchange_rate_applied, 2)
                            ELSE amount_paid
                        END), 0)
      INTO v_paid_fiat
      FROM sale_payments WHERE sale_id = p_sale_id;

    IF v_paid_fiat < v_sale.total_fiat THEN
        RAISE EXCEPTION 'Sale % is underpaid: paid % VES of % VES',
                        p_sale_id, v_paid_fiat, v_sale.total_fiat
              USING ERRCODE = 'check_violation';
    END IF;
END;
$$;

CREATE FUNCTION trg_check_sale_integrity()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_TABLE_NAME = 'sales' THEN
        PERFORM check_sale_integrity(NEW.id);
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM check_sale_integrity(OLD.sale_id);
    ELSE
        PERFORM check_sale_integrity(NEW.sale_id);
        IF TG_OP = 'UPDATE' AND OLD.sale_id <> NEW.sale_id THEN
            PERFORM check_sale_integrity(OLD.sale_id);
        END IF;
    END IF;
    RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER sales_integrity
    AFTER INSERT OR UPDATE ON sales
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION trg_check_sale_integrity();

CREATE CONSTRAINT TRIGGER sale_details_integrity
    AFTER INSERT OR DELETE ON sale_details
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION trg_check_sale_integrity();

CREATE CONSTRAINT TRIGGER sale_payments_integrity
    AFTER INSERT OR UPDATE OR DELETE ON sale_payments
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION trg_check_sale_integrity();


-- =============================================================================
-- 4. CONVENIENCE VIEWS
-- =============================================================================

-- Most recent exchange rate.
CREATE VIEW current_exchange_rate AS
SELECT id, usd_rate, updated_at
  FROM exchange_rates
 ORDER BY updated_at DESC
 LIMIT 1;

-- Stock per branch with a low-stock flag.
CREATE VIEW branch_stock_status AS
SELECT bi.id                                AS branch_inventory_id,
       bi.branch,
       p.id                                 AS product_id,
       p.name                               AS product_name,
       p.category,
       p.unit_measure,
       bi.current_stock,
       bi.minimum_stock,
       bi.current_stock <= bi.minimum_stock AS is_low_stock
  FROM branch_inventory bi
  JOIN products p ON p.id = bi.product_id
 WHERE p.is_active;

COMMIT;
