-- =============================================================================
--  seed_data.sql
--  Sample data for local development and smoke testing.
--  Requires init_schema.sql to have been applied first.
--
--  Natural keys (user / product names) are used instead of hard-coded ids, so
--  the script does not depend on identity sequence values.
--
--  Demo credentials (development only!):
--    Maria Gonzalez  / Manager123!     (MANAGER,    all branches)
--    Carlos Perez    / Supervisor123!  (SUPERVISOR, VILLA_LIBERTAD)
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- 1. Users (bcrypt hashes generated with pgcrypto)
-- -----------------------------------------------------------------------------
INSERT INTO users (name, password_hash, role, assigned_branch) VALUES
    ('Maria Gonzalez', crypt('Manager123!',    gen_salt('bf', 10)), 'MANAGER',    'ALL'),
    ('Carlos Perez',   crypt('Supervisor123!', gen_salt('bf', 10)), 'SUPERVISOR', 'VILLA_LIBERTAD');


-- -----------------------------------------------------------------------------
-- 2. Exchange rate (VES per 1 USD)
-- -----------------------------------------------------------------------------
INSERT INTO exchange_rates (usd_rate) VALUES (150.2500);


-- -----------------------------------------------------------------------------
-- 3. Global catalog
-- -----------------------------------------------------------------------------
INSERT INTO products (name, category, unit_measure, cost_price_usd, sale_price_usd) VALUES
    ('Multipurpose Liquid Detergent', 'LIQUIDS',     'LTS',   1.20, 2.00),
    ('Laundry Powder Soap',           'POWDERS',     'KG',    1.50, 2.50),
    ('Microfiber Cleaning Cloth',     'ACCESSORIES', 'UNITS', 0.60, 1.25);


-- -----------------------------------------------------------------------------
-- 4. Branch inventory
--    Rows are created with stock 0; the opening stock is loaded through
--    INBOUND movements so the ledger fully explains every unit on hand.
-- -----------------------------------------------------------------------------
INSERT INTO branch_inventory (product_id, branch, minimum_stock)
SELECT p.id, b.branch, b.minimum_stock
  FROM products p
  JOIN (VALUES
          ('Multipurpose Liquid Detergent', 'VILLA_LIBERTAD'::branch, 10.000),
          ('Laundry Powder Soap',           'VILLA_LIBERTAD'::branch, 10.000),
          ('Microfiber Cleaning Cloth',     'VILLA_LIBERTAD'::branch, 20.000),
          ('Multipurpose Liquid Detergent', 'LAS_AMERICAS'::branch,    8.000),
          ('Laundry Powder Soap',           'LAS_AMERICAS'::branch,    8.000),
          ('Microfiber Cleaning Cloth',     'LAS_AMERICAS'::branch,   15.000)
       ) AS b (product_name, branch, minimum_stock)
    ON b.product_name = p.name;

-- Opening stock, received by the manager (who has access to ALL branches).
INSERT INTO inventory_movements (user_id, branch_inventory_id, movement_type, affected_quantity)
SELECT u.id, bi.id, 'INBOUND', s.quantity
  FROM (VALUES
          ('Multipurpose Liquid Detergent', 'VILLA_LIBERTAD'::branch,  50.000),
          ('Laundry Powder Soap',           'VILLA_LIBERTAD'::branch,  40.000),
          ('Microfiber Cleaning Cloth',     'VILLA_LIBERTAD'::branch, 100.000),
          ('Multipurpose Liquid Detergent', 'LAS_AMERICAS'::branch,    30.000),
          ('Laundry Powder Soap',           'LAS_AMERICAS'::branch,    25.000),
          ('Microfiber Cleaning Cloth',     'LAS_AMERICAS'::branch,    12.000)
       ) AS s (product_name, branch, quantity)
  JOIN products         p  ON p.name = s.product_name
  JOIN branch_inventory bi ON bi.product_id = p.id AND bi.branch = s.branch
  JOIN users            u  ON u.name = 'Maria Gonzalez';


-- -----------------------------------------------------------------------------
-- 5. One complete sale at VILLA_LIBERTAD
--
--    Line items (rate 150.25 VES/USD):
--      2.500 LTS  x 2.00 = 5.00 USD   Multipurpose Liquid Detergent
--      2.000 KG   x 2.50 = 5.00 USD   Laundry Powder Soap
--      3 UNITS    x 1.25 = 3.75 USD   Microfiber Cleaning Cloth
--      -------------------------------
--      total_usd  = 13.75 USD
--      total_fiat = 13.75 x 150.25 = 2,065.94 VES
--
--    Payments (split tender):
--      CASH_USD      10.00 USD  (= 1,502.50 VES)
--      POS_TERMINAL 563.44 VES
--      -------------------------------
--      paid         2,065.94 VES  -> fully covered
-- -----------------------------------------------------------------------------
DO $$
DECLARE
    v_user_id     BIGINT;
    v_session_id  BIGINT;
    v_sale_id     BIGINT;
    v_rate        NUMERIC(14,4);
BEGIN
    SELECT id INTO STRICT v_user_id FROM users WHERE name = 'Carlos Perez';
    SELECT usd_rate INTO STRICT v_rate FROM current_exchange_rate;

    -- Open the register for the shift.
    INSERT INTO cash_sessions (user_id, branch, initial_cash_fund)
    VALUES (v_user_id, 'VILLA_LIBERTAD', 20.00)
    RETURNING id INTO v_session_id;

    -- A petty-cash expense during the shift.
    INSERT INTO cash_expenses (cash_session_id, expense_reason, amount)
    VALUES (v_session_id, 'Drinking water for staff', 1.50);

    -- Sale header (totals are validated against lines/payments at COMMIT).
    INSERT INTO sales (user_id, cash_session_id, branch,
                       customer_id_document, customer_name,
                       exchange_rate_applied, total_usd, total_fiat)
    VALUES (v_user_id, v_session_id, 'VILLA_LIBERTAD',
            'V-12345678', 'Ana Rodriguez',
            v_rate, 13.75, round(13.75 * v_rate, 2))
    RETURNING id INTO v_sale_id;

    -- Line items: unit price is taken from the catalog at sale time.
    -- Each insert also writes a SALE movement that discounts branch stock.
    INSERT INTO sale_details (sale_id, product_id, quantity, unit_price_usd, subtotal_usd)
    SELECT v_sale_id, p.id, l.quantity, p.sale_price_usd, round(l.quantity * p.sale_price_usd, 2)
      FROM (VALUES
              ('Multipurpose Liquid Detergent', 2.500),
              ('Laundry Powder Soap',           2.000),
              ('Microfiber Cleaning Cloth',     3.000)
           ) AS l (product_name, quantity)
      JOIN products p ON p.name = l.product_name;

    -- Split payment.
    INSERT INTO sale_payments (sale_id, payment_method, currency, amount_paid, approval_reference) VALUES
        (v_sale_id, 'CASH_USD',     'USD',  10.00, NULL),
        (v_sale_id, 'POS_TERMINAL', 'VES', 563.44, 'AUTH-004512');
END;
$$;

COMMIT;
