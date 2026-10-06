-- =============================================================================
--  smoke_tests.sql
--  Read-only reports + constraint tests. Everything runs inside a transaction
--  that is ROLLED BACK at the end, so the database is left unchanged.
--
--  Run:  docker compose exec db psql -U pos_admin -d pos_db -f /tests/smoke_tests.sql
-- =============================================================================

\set ON_ERROR_STOP on
\pset footer off

BEGIN;

\echo '=== 1. Total sales per branch ==='
SELECT branch,
       count(*)        AS sales_count,
       sum(total_usd)  AS total_usd,
       sum(total_fiat) AS total_ves
  FROM sales
 GROUP BY branch
 ORDER BY branch;

\echo '=== 2. Inventory levels per branch (low stock flagged) ==='
SELECT branch, product_name, unit_measure, current_stock, minimum_stock, is_low_stock
  FROM branch_stock_status
 ORDER BY branch, product_name;

\echo '=== 3. Ledger reconciliation (must return 0 rows) ==='
SELECT bi.id, bi.current_stock, coalesce(sum(m.affected_quantity), 0) AS ledger_stock
  FROM branch_inventory bi
  LEFT JOIN inventory_movements m ON m.branch_inventory_id = bi.id
 GROUP BY bi.id
HAVING bi.current_stock <> coalesce(sum(m.affected_quantity), 0);

\echo '=== 4. Payments breakdown per method / currency ==='
SELECT sp.payment_method, sp.currency, sum(sp.amount_paid) AS amount
  FROM sale_payments sp
 GROUP BY sp.payment_method, sp.currency
 ORDER BY sp.payment_method;

\echo '=== 5. Gross margin per sale line ==='
SELECT s.id AS sale_id, p.name, sd.quantity, sd.subtotal_usd,
       round(sd.quantity * p.cost_price_usd, 2)                   AS cost_usd,
       sd.subtotal_usd - round(sd.quantity * p.cost_price_usd, 2) AS margin_usd
  FROM sale_details sd
  JOIN sales    s ON s.id = sd.sale_id
  JOIN products p ON p.id = sd.product_id
 ORDER BY s.id, p.name;

\echo '=== 6. Constraint tests (each one must report PASS) ==='

-- Helper: runs a statement and passes only if it raises an error.
CREATE FUNCTION pg_temp.expect_error(p_label TEXT, p_sql TEXT)
RETURNS TEXT LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        EXECUTE p_sql;
        SET CONSTRAINTS ALL IMMEDIATE;   -- fire deferred sale-integrity checks now
    EXCEPTION WHEN OTHERS THEN
        RETURN 'PASS  ' || p_label || '  -> ' || SQLERRM;
    END;
    RAISE EXCEPTION 'FAIL  % (statement was accepted)', p_label;
END;
$$;

SELECT pg_temp.expect_error('negative sale price',
  $q$INSERT INTO products (name, category, unit_measure, cost_price_usd, sale_price_usd)
     VALUES ('Bad product', 'OTHER', 'UNITS', 1, -1)$q$);

SELECT pg_temp.expect_error('stock in branch ALL',
  $q$INSERT INTO branch_inventory (product_id, branch)
     SELECT id, 'ALL' FROM products LIMIT 1$q$);

SELECT pg_temp.expect_error('overselling (stock below zero)',
  $q$INSERT INTO inventory_movements (user_id, branch_inventory_id, movement_type, affected_quantity)
     SELECT u.id, bi.id, 'SHRINKAGE', -99999
       FROM users u, branch_inventory bi LIMIT 1$q$);

SELECT pg_temp.expect_error('INBOUND with negative quantity',
  $q$INSERT INTO inventory_movements (user_id, branch_inventory_id, movement_type, affected_quantity)
     SELECT u.id, bi.id, 'INBOUND', -5 FROM users u, branch_inventory bi LIMIT 1$q$);

SELECT pg_temp.expect_error('ledger is append-only',
  $q$DELETE FROM inventory_movements$q$);

SELECT pg_temp.expect_error('supervisor operating in another branch',
  $q$INSERT INTO cash_sessions (user_id, branch)
     SELECT id, 'LAS_AMERICAS' FROM users WHERE name = 'Carlos Perez'$q$);

SELECT pg_temp.expect_error('deleting a product that was sold',
  $q$DELETE FROM products WHERE name = 'Laundry Powder Soap'$q$);

SELECT pg_temp.expect_error('CASH_USD paid in VES',
  $q$INSERT INTO sale_payments (sale_id, payment_method, currency, amount_paid)
     SELECT id, 'CASH_USD', 'VES', 1 FROM sales LIMIT 1$q$);

SELECT pg_temp.expect_error('POS payment without approval reference',
  $q$INSERT INTO sale_payments (sale_id, payment_method, currency, amount_paid)
     SELECT id, 'POS_TERMINAL', 'VES', 1 FROM sales LIMIT 1$q$);

SELECT pg_temp.expect_error('total_fiat inconsistent with rate',
  $q$UPDATE sales SET total_fiat = total_fiat + 1$q$);

SELECT pg_temp.expect_error('total_usd not matching its lines',
  $q$UPDATE sales SET total_usd = 1.00, total_fiat = round(1.00 * exchange_rate_applied, 2)$q$);

SELECT pg_temp.expect_error('underpaid sale',
  $q$DELETE FROM sale_payments WHERE payment_method = 'POS_TERMINAL'$q$);

-- Close every session (rolled back at the end), then try to sell in one.
UPDATE cash_sessions SET closed_at = now() WHERE closed_at IS NULL;

SELECT pg_temp.expect_error('sale in a closed cash session',
  $q$INSERT INTO sales (user_id, cash_session_id, branch, exchange_rate_applied, total_usd, total_fiat)
     SELECT user_id, id, branch, 1, 0, 0 FROM cash_sessions LIMIT 1$q$);

ROLLBACK;

\echo '=== All smoke tests passed (transaction rolled back) ==='
