# Contratos de la API del backend POS

Fuente: código de `pos_backend/` y `openapi.yaml` (generado con `manage.py spectacular`) al
2026-10-12. **El backend es la fuente de verdad**: si este documento y el backend difieren, manda
el backend y este archivo se regenera.

## Convenciones generales

- **Base**: `/api/v1/`. Todas las rutas terminan en `/`.
- **Autenticación**: cabecera `Authorization: Bearer <access>`. Solo `auth/login/` y
  `auth/refresh/` son públicas.
- **Roles**: `MANAGER`, `SUPERVISOR`. "Operador" = cualquiera de los dos.
- **Decimales**: montos (2 decimales), cantidades (3) y tasas (4) llegan y se envían como
  **string decimal** (`"12.50"`, `"3.000"`, `"872.3900"`). Única excepción: `sales_count` es entero.
  La tasa del BCV llega ya redondeada a 2 decimales (`"872.3900"`); una manual puede traer hasta 4.
- **Fechas**: ISO 8601 con zona (`"2026-10-06T10:15:00-04:00"`), zona `America/Caracas`.
- **IDs**: enteros. Las relaciones (`user`, `product`, `cash_session`, `sale`, `created_by`) llegan
  como id entero, **sin objeto anidado ni nombre**. La sucursal llega como su `code` (string).

### Paginación

Todos los listados usan paginación por página. Parámetros: `page` (desde 1) y `page_size`
(por defecto 25, máximo 200).

```json
{"count": 123, "next": "http://.../?page=2", "previous": null, "results": [ ... ]}
```

Una página fuera de rango responde 404 `not_found`.

### Sobre de error

Todos los errores, de negocio o de DRF, responden con el mismo sobre:

```json
{"code": "insufficient_stock", "detail": "No hay stock suficiente...", "meta": { ... }}
```

Errores transversales:

| `code` | HTTP | Cuándo | `meta` |
|---|---|---|---|
| `validation_error` | 400 | El body o la query no pasan el serializer | `errors`: `{campo: [mensajes]}` |
| `authentication_failed` | 401 | Login con credenciales malas o usuario inactivo | — |
| `not_authenticated` | 401 | Falta el token | — |
| `token_not_valid` | 401 | Access vencido o inválido; refresh vencido o inválido | puede traer `messages` |
| `permission_denied` | 403 | El rol no puede usar el endpoint | — |
| `not_found` | 404 | Ruta o página inexistente | — |

### Cómo se envía la sucursal

| Tipo de endpoint | Dónde va `branch` |
|---|---|
| `GET` de listados y reportes (`inventory/`, `inventory/low-stock/`, `inventory/movements/`, `cash-sessions/`, `sales/`, `sales/reports/summary/`) | Query `?branch=CODE` |
| `POST`/`PATCH` (`inventory/movements/`, `inventory/<id>/minimum-stock/`, `cash-sessions/`, `sales/`) | Campo `branch` en el body |
| Recursos por id (`cash-sessions/<id>/...`, `sales/<id>/`) | No se envía: la sucursal es la del recurso |
| Catálogo, usuarios, tasas, sucursales | No aplica |

`branch` es siempre **opcional**. Sin él, el backend resuelve:

- Usuario con `assigned_branch`: su sucursal.
- MANAGER con `assigned_branch = null`: la única sucursal activa si solo hay una; si hay varias,
  400 `branch_required` (`meta.allowed` = códigos activos); si no hay ninguna, 409 `no_branches`.
- Excepción: en `GET cash-sessions/`, `GET sales/` y `GET sales/reports/summary/`, un MANAGER con
  acceso a todas que no envía `branch` recibe los datos de **todas** las sucursales.

Errores de sucursal: `invalid_branch` (400, `meta.branch`, `meta.allowed`), `branch_access_denied`
(403, `meta.requested_branch`, `meta.assigned_branch`), `branch_required` (400), `no_branches` (409).

## Enums (valores exactos)

| Enum | Valores (etiqueta en español) |
|---|---|
| `role` | `MANAGER` (Gerente), `SUPERVISOR` (Supervisor) |
| `unit_of_measure` | `LITER` (Litro), `KILOGRAM` (Kilogramo), `UNIT` (Unidad) |
| `movement_type` | `ENTRY` (Entrada), `SALE` (Venta), `WASTE` (Merma), `ADJUSTMENT` (Ajuste) |
| `method` | `POS_CARD` (Punto de venta), `CASH_VES` (Efectivo VES), `CASH_USD` (Efectivo USD), `MOBILE_PAYMENT` (Pago móvil), `CREDIT` (Crédito) |
| `currency` | `VES` (Bolívares), `USD` (Dólares) |

Moneda obligatoria por método: `CASH_USD` y `CREDIT` → `USD`; `CASH_VES`, `POS_CARD`,
`MOBILE_PAYMENT` → `VES`. `CREDIT` solo vale en una venta (lo que el cliente se lleva sin pagar).

## Auth

| Método y ruta | Permiso | Body | Respuesta |
|---|---|---|---|
| `POST auth/login/` | Público | `{username, password}` | 200 `{access, refresh}` |
| `POST auth/refresh/` | Público | `{refresh}` | 200 `{access}` (el refresh **no** rota) |
| `GET auth/me/` | Autenticado | — | 200 `User` |

`User`: `{id, username, full_name, role, assigned_branch, is_active}`. `assigned_branch` es un código
o `null` (= todas, solo MANAGER). Access dura 30 min y refresh 12 h.

## Usuarios (solo MANAGER)

| Método y ruta | Body / query | Respuesta |
|---|---|---|
| `GET users/` | `?active=true` | Página de `User` |
| `POST users/` | `{username, password (≥8), full_name, role, assigned_branch}` (`assigned_branch` obligatorio, admite `null`) | 201 `User` |
| `GET users/<id>/` | — | `User` |
| `PATCH users/<id>/` | Cualquiera de `{full_name, role, assigned_branch, is_active, password}` | `User` |

Errores: `invalid_username`, `invalid_full_name`, `invalid_password` (422, `meta.errors`),
`invalid_branch_assignment` (422, SUPERVISOR sin sucursal), `invalid_branch` (400),
`username_taken` (409), `user_not_found` (404), `user_has_open_session` (409, al desactivar o
cambiar de sucursal), `cannot_modify_own_access` (409). No existe borrado: se desactiva.

## Sucursales

| Método y ruta | Permiso | Body / query | Respuesta |
|---|---|---|---|
| `GET branches/` | Operador | `?active=true` | Página de `Branch` |
| `POST branches/` | MANAGER | `{code, name}` | 201 `Branch` |
| `GET branches/<code>/` | Operador | — | `Branch` |
| `PATCH branches/<code>/` | MANAGER | `{name?, active?}` | `Branch` |

`Branch`: `{code, name, active}`. El `code` se normaliza a mayúsculas, cumple
`^[A-Z][A-Z0-9_]{0,19}$` y no se puede cambiar. Errores: `invalid_branch_code` (422),
`invalid_branch_name` (422), `branch_code_taken` (409), `branch_not_found` (404),
`branch_has_open_sessions` (409, al desactivar).

## Categorías

Las categorías son filas que crea un MANAGER, no un enum. No hay categorías por defecto. No se
borran: se desactivan.

| Método y ruta | Permiso | Body / query | Respuesta |
|---|---|---|---|
| `GET categories/` | Operador | `?active=true` | Página de `Category`, por nombre |
| `POST categories/` | MANAGER | `{name, icon?}` | 201 `Category` |
| `GET categories/<id>/` | Operador | — | `Category` |
| `PATCH categories/<id>/` | MANAGER | `{name?, icon?, active?}` | `Category` |

`Category`: `{id, name, icon, active}`. `icon` es el sticker (un emoji) que elige el MANAGER;
vacío significa que la app le asigna un ícono. El nombre no se repite, sin distinguir mayúsculas. Una categoría
inactiva conserva sus productos, pero no admite productos nuevos. Errores:
`invalid_category_name` (422), `category_name_taken` (409), `category_not_found` (404).

## Subcategorías

Segundo nivel del catálogo, dentro de una categoría. Son opcionales: un producto puede no tener.
No se borran (se desactivan) ni cambian de categoría.

| Método y ruta | Permiso | Body / query | Respuesta |
|---|---|---|---|
| `GET subcategories/` | Operador | `?category=<id>&active=true` | Página de `Subcategory`, por nombre |
| `POST subcategories/` | MANAGER | `{category, name}` | 201 `Subcategory` |
| `GET subcategories/<id>/` | Operador | — | `Subcategory` |
| `PATCH subcategories/<id>/` | MANAGER | `{name?, active?}` | `Subcategory` |

`Subcategory`: `{id, category, name, active}`. El nombre no se repite dentro de la misma
categoría, sin distinguir mayúsculas. Errores: `invalid_subcategory_name` (422),
`subcategory_name_taken` (409), `subcategory_not_found` (404), y al crear `category_not_found`
(404) o `inactive_category` (422).

Un producto lleva `subcategory` (id o `null`) y `subcategory_name`; `GET products/` admite
`?subcategory=<id>`. Al asignarla debe estar activa y ser de la categoría del producto:
`inactive_subcategory` o `subcategory_category_mismatch` (422). Si un `PATCH` cambia la categoría
sin enviar `subcategory`, el producto queda sin subcategoría.

## Productos (catálogo global)

| Método y ruta | Permiso | Body / query | Respuesta |
|---|---|---|---|
| `GET products/` | Operador | `?active=true`, `?category=<id>`, `?search=` (texto en el nombre) | Página de `Product`, por nombre |
| `POST products/` | MANAGER | `{name, category, unit_of_measure, cost_price_usd, sale_price_usd}` (`category` = id) | 201 `Product` |
| `GET products/<id>/` | Operador | — | `Product` |
| `PATCH products/<id>/` | MANAGER | Cualquiera de los campos de alta | `Product` |
| `POST products/<id>/toggle-active/` | MANAGER | Sin body | `Product` |

`Product`: `{id, name, category, category_name, category_icon, unit_of_measure, cost_price_usd,
sale_price_usd, active}`. `category` es el id de la categoría; `category_name` y `category_icon`
son su nombre y su sticker (solo lectura).
**No incluye stock ni imagen.** Errores: `invalid_name` (422), `product_name_taken` (409),
`invalid_price` (422), `product_not_found` (404), `category_not_found` (404),
`inactive_category` (422, al crear o al pasar el producto a una categoría inactiva).

## Inventario

| Método y ruta | Permiso | Body / query | Respuesta |
|---|---|---|---|
| `GET inventory/` | Operador | `?branch=` | Página de `BranchInventory`, por nombre de producto |
| `GET inventory/low-stock/` | Operador | `?branch=` | Página de `BranchInventory` (activos con stock ≤ mínimo) |
| `PATCH inventory/<product_id>/minimum-stock/` | MANAGER | `{minimum_stock, branch?}` | `BranchInventory` |
| `GET inventory/movements/` | Operador | `?branch=`, `?product=<id>`, `?movement_type=`, `?created_from=`, `?created_to=` | Página de `InventoryMovement`, más reciente primero |
| `POST inventory/movements/` | Operador | `{product_id, movement_type, quantity, branch?, notes?}` | 201 `InventoryMovement`, o **204 sin cuerpo** si un ajuste coincide con el stock actual |

`BranchInventory`: `{id, product, product_name, branch, current_stock, minimum_stock}`.
`InventoryMovement`: `{id, product, branch, movement_type, quantity, stock_before, stock_after,
user, sale, notes, created_at}`. `quantity` es siempre positiva; el sentido lo dan el tipo y
`stock_before`/`stock_after`.

- `movement_type` manual admite solo `ENTRY`, `WASTE`, `ADJUSTMENT`. En `ADJUSTMENT`, `quantity`
  es el **stock contado**, no la diferencia.
- Errores: `invalid_quantity` (422), `inactive_product` (422, entrada de un producto inactivo),
  `insufficient_stock` (422, merma mayor que el stock), `product_not_found` (404).

**Limitaciones confirmadas** (afectan al diseño de la app):

1. `inventory/` **no tiene filtros** de búsqueda, categoría ni producto, y no devuelve categoría,
   unidad ni precio. La app debe cruzar `products/` con `inventory/` por `product` en el cliente.
2. **No existe un endpoint para comparar stock entre sucursales.** La app consulta
   `inventory/?branch=<code>` por cada sucursal activa en paralelo y filtra por producto en el cliente.
3. Un producto puede no tener fila en `inventory/` de una sucursal: se trata como stock 0.

## Tasa de cambio

| Método y ruta | Permiso | Body | Respuesta |
|---|---|---|---|
| `GET exchange-rates/` | Operador | — | Página de `ExchangeRate`, más reciente primero |
| `POST exchange-rates/` | MANAGER | `{usd_to_ves_rate}` | 201 `ExchangeRate` |
| `GET exchange-rates/current/` | Operador | — | `ExchangeRate` |
| `GET exchange-rates/bcv/` | Operador | — | `{rate, updated_at}` |
| `POST exchange-rates/bcv/sync/` | MANAGER | Sin body | 201 `ExchangeRate` si el BCV publicó una tasa nueva; 200 con la activa si no cambió |

`ExchangeRate`: `{id, usd_to_ves_rate, source, effective_date, created_by, created_at}`.

- `source`: `MANUAL` (la registró un MANAGER) o `BCV` (sincronización automática).
- `effective_date`: día al que corresponde la tasa según el BCV (`"2026-10-06"`); `null` en las
  manuales.
- `created_by`: `null` en las tasas automáticas.

Errores: `exchange_rate_not_set` (409, todavía no hay tasa: no se puede facturar ni cerrar caja),
`invalid_exchange_rate` (422), `bcv_rate_unavailable` (503).

**Tasa automática.** El comando `python manage.py sync_bcv_rate` (programado con cron cada hora)
registra la tasa del BCV como activa cada vez que el BCV publica una nueva. Una tasa manual vale
hasta la siguiente publicación del BCV. La app detecta el cambio comparando el `id` de
`exchange-rates/current/` con el último que vio. `GET exchange-rates/bcv/` sigue siendo solo
consulta, con caché de 6 horas.

## Configuración de precios

| Método y ruta | Permiso | Body | Respuesta |
|---|---|---|---|
| `GET pricing-settings/` | Operador | — | `PricingSettings` |
| `PATCH pricing-settings/` | MANAGER | `{rate_mode?, round_ves_up?}` | `PricingSettings` |

`PricingSettings`: `{rate_mode, round_ves_up}`. Por defecto `BCV` y `false`.

- `rate_mode = BCV`: la tasa activa sigue a la del BCV (ver "Tasa automática"). `MANUAL`: manda
  la tasa que registre un MANAGER; `sync_bcv_rate` y `bcv/sync/` no registran nada. Al volver a
  `BCV` se registra de inmediato la tasa del BCV como activa; si no se puede consultar responde
  `bcv_rate_unavailable` (503) y no cambia nada.
- `round_ves_up`: el **precio unitario** en VES se redondea **hacia arriba al bolívar entero**; el
  subtotal no vuelve a subir. Regla del backend, que la app replica en `VesPricing`: precio
  unitario VES = techo(precio USD × tasa); subtotal de línea VES = cantidad × precio unitario VES
  a 2 decimales (litro a 797 Bs → medio litro 398,50 Bs); total VES = suma de subtotales.
  Los importes en USD no cambian. Solo afecta a ventas nuevas.
- Con el redondeo, `total_ves` ya no es `total_usd × tasa`. Los pagos en VES se convierten a USD
  con la proporción de la venta (`total_ves ÷ total_usd`) en vez de con la tasa, de modo que pagar
  `total_ves` cuadra exactamente. `exchange_rate_at_invoice` sigue siendo la tasa real.

## Cajas

| Método y ruta | Permiso | Body / query | Respuesta |
|---|---|---|---|
| `GET cash-sessions/` | Operador | `?branch=`, `?only_open=true` | Página de `CashSession`, más reciente primero |
| `POST cash-sessions/` | Operador | `{opening_float, branch?}` | 201 `CashSession` |
| `GET cash-sessions/current/` | Operador | — | `CashSession` abierta del usuario |
| `GET cash-sessions/<id>/expenses/` | Operador | — | Página de `CashExpense` |
| `POST cash-sessions/<id>/expenses/` | Dueño o MANAGER | `{reason, amount, currency}` | 201 `CashExpense` |
| `GET cash-sessions/<id>/summary/` | Operador | — | `CashCountSummary` |
| `GET cash-sessions/<id>/sales-report/` | Operador | — | `SessionSalesReport` |
| `POST cash-sessions/<id>/close/` | Dueño o MANAGER | `{counted_amount_usd, counted_amount_ves}` | `CashSession` cerrada |

`CashSession`: `{id, user, branch, opened_at, closed_at, opening_float, counted_amount_usd,
counted_amount_ves, difference_usd}`. Abierta ⇔ `closed_at == null`. `opening_float` está en USD.
`CashExpense`: `{id, cash_session, reason, amount, currency, created_by, created_at}`.
`CashCountSummary`: `{opening_float, cash_sales_usd, cash_sales_ves, electronic_sales_usd,
electronic_sales_ves, expenses_usd, expenses_ves, credit_cash_usd, credit_cash_ves,
credit_electronic_ves, expected_cash_usd, expected_cash_ves}`. `credit_*` son los abonos de
deudas cobrados en la caja; lo vendido a crédito no entra en ningún total del arqueo.

`SessionSalesReport`: `{sales_count, total_usd, total_ves, cost_usd, cost_ves, profit_usd,
profit_ves, payments: [{method, currency, amount}], products: [{product, product_name, quantity,
sales_usd, sales_ves, cost_usd, cost_ves, profit_usd, profit_ves}], credit_collections:
[{method, currency, amount}]}`. Sirve para una caja abierta o cerrada. `payments` incluye `CREDIT`
(lo vendido a crédito); `credit_collections` son los abonos de deudas cobrados en la caja.

- `cost_*` es la inversión: cantidad × costo del producto **al facturar** (cada línea de venta
  guarda su `unit_cost_usd`; no se expone en `Sale`). `profit_*` = total − costo. Los gastos de
  caja no se descuentan.
- Los bolívares vendidos de cada producto son los facturados, a la tasa de su venta. Los del
  costo usan **siempre la tasa del BCV** congelada en la venta, aunque se haya cobrado con una
  tasa manual: `profit_ves` = facturado − costo al BCV.
- `payments` agrupa lo cobrado por método, en la moneda del método. `products` va del que más
  vendió al que menos.
- Esperado USD = fondo + ventas efectivo USD + abonos efectivo USD − egresos USD. Esperado VES =
  ventas efectivo VES + abonos efectivo VES − egresos VES. `electronic_*` y
  `credit_electronic_ves` (punto y pago móvil) son informativos.
- `difference_usd` = (contado USD − esperado USD) + (contado VES − esperado VES) convertido a USD
  con la tasa activa. Positiva = sobrante; negativa = faltante.
- Una sola caja abierta por usuario. Errores: `no_open_session` (409), `session_already_open`
  (409, `meta.cash_session_id`, `meta.branch`), `session_already_closed` (409),
  `cash_session_not_found` (404), `not_session_owner` (403), `invalid_amount` (422),
  `invalid_reason` (422), `exchange_rate_not_set` (409, al cerrar).

## Ventas

| Método y ruta | Permiso | Body / query | Respuesta |
|---|---|---|---|
| `GET sales/` | Operador | `?branch=`, `?cash_session=<id>`, `?date_from=`, `?date_to=` | Página de `Sale`, más reciente primero |
| `POST sales/` | Operador | Ver abajo | 201 `Sale` |
| `GET sales/<id>/` | Operador | — | `Sale` |
| `GET sales/reports/summary/` | Operador | `?branch=`, `?date_from=`, `?date_to=` | `{sales_count, total_usd, total_ves}` |

### `POST sales/`

```json
{
  "branch": "PRINCIPAL",
  "customer_tax_id": "V12345678",
  "customer_name": "Ana Pérez",
  "items": [{"product_id": 3, "quantity": "2.500"}],
  "payments": [
    {"method": "CASH_USD", "currency": "USD", "amount": "5.00"},
    {"method": "MOBILE_PAYMENT", "currency": "VES", "amount": "1500.00", "approval_reference": "004512"}
  ]
}
```

- `branch`, `customer_tax_id` (máx. 20) y `customer_name` (máx. 150) son opcionales. Sin `branch`
  se factura en la sucursal de la caja abierta.
- **Venta a crédito**: un pago `{"method": "CREDIT", "currency": "USD", "amount": "6.00"}` deja
  ese monto como deuda del cliente en USD. Exige `customer_id` (cliente activo) y admite
  `credit_days` (0–365; sin él, el plazo del cliente). Solo puede haber un pago `CREDIT`; el resto
  de los pagos es lo que el cliente da al llevarse los productos. El nombre y la cédula del
  cliente se copian a la venta si no vienen.
- **El precio nunca se envía**: sale de la base de datos. La tasa activa se congela en la venta.
- Los pagos deben cuadrar con el total dentro de 0,01 USD, **tanto si falta como si sobra**. El
  vuelto no existe en el backend: la app envía el monto exacto.
- Los pagos en VES se suman entre sí y se convierten a USD una sola vez con la tasa activa.

Respuesta 201, `Sale`:

```json
{
  "id": 41, "cash_session": 7, "user": 2, "branch": "PRINCIPAL",
  "customer_tax_id": "V12345678", "customer_name": "Ana Pérez",
  "customer": null, "credit_due_date": null,
  "exchange_rate_at_invoice": "150.0000", "total_usd": "15.00", "total_ves": "2250.00",
  "created_at": "2026-10-06T10:15:00-04:00",
  "details": [{"id": 90, "product": 3, "quantity": "2.500", "unit_price_usd": "6.00", "subtotal_usd": "15.00", "subtotal_ves": "2250.00"}],
  "payments": [{"id": 77, "method": "CASH_USD", "currency": "USD", "amount": "5.00", "approval_reference": ""}]
}
```

`details[].product` es solo el id: **el nombre del producto no viene en la venta**.
`customer` y `credit_due_date` (fecha `YYYY-MM-DD`) solo vienen en las ventas a crédito.
`details[].subtotal_ves` es lo facturado en bolívares por la línea; con el redondeo activo no
coincide con `subtotal_usd × tasa`, así que se muestra siempre ese valor.

| `code` | HTTP | `meta` |
|---|---|---|
| `no_open_session` | 409 | vacío, o `requested_branch` y `open_session_branch` |
| `exchange_rate_not_set` | 409 | — |
| `inactive_product` | 422 | `product_ids`: ids inexistentes o inactivos |
| `insufficient_stock` | 422 | `items`: `[{product_id, requested, available}]` |
| `payment_mismatch` | 422 | `expected_usd`, `paid_usd`, `difference_usd`, `tolerance_usd` |
| `invalid_payment` | 422 | `payment_index`, y según el caso `method`, `currency` |
| `invalid_quantity` | 422 | `product_id`, `quantity` |
| `empty_sale` | 422 | — |
| `sale_not_found` | 404 | `sale_id` |
| `customer_required` | 422 | — (pago `CREDIT` sin `customer_id`) |
| `inactive_customer` | 422 | `customer_id` |
| `invalid_credit_days` | 422 | `credit_days`, `max_credit_days` |

## Clientes a crédito

| Método y ruta | Permiso | Body / query | Respuesta |
|---|---|---|---|
| `GET customers/` | Operador | `?branch=`, `?search=`, `?active=true`, `?with_debt=true` | Página de `Customer`, por nombre |
| `POST customers/` | Operador | `{name, tax_id?, phone?, credit_days?}` | 201 `Customer` |
| `GET customers/<id>/` | Operador | `?branch=` | `Customer` |
| `PATCH customers/<id>/` | Operador | `{name?, tax_id?, phone?, credit_days?, active?}` | `Customer` |
| `GET customers/<id>/payments/` | Operador | `?branch=` | Página de `CreditPayment`, más reciente primero |
| `POST customers/<id>/payments/` | Operador con caja abierta | `{method, currency, amount, approval_reference?}` | 201 `CreditPayment` |
| `GET credits/` | Operador | `?branch=`, `?customer=<id>`, `?status=PENDING\|OVERDUE\|PAID\|ALL` (por defecto `PENDING`) | Página de `Credit`, la que vence antes primero |

`Customer`: `{id, name, tax_id, phone, credit_days, active, balance_usd, overdue_usd,
open_credits, next_due_date, balance_ves, payment_rate, created_at}`. Los clientes son de todo el
negocio; los saldos, de la sucursal indicada (un MANAGER sin sucursal y sin `branch` ve la deuda
total). `balance_ves` = `balance_usd` × `payment_rate`, la tasa del BCV del día; ambos llegan
`null` si no hay tasa del BCV. La cédula (`tax_id`) se guarda en mayúsculas y no se repite.

`Credit`: `{id, sale, customer, customer_name, customer_phone, branch, amount_usd, balance_usd,
due_date, paid_at, is_overdue, created_at}`. `due_date` es fecha `YYYY-MM-DD`.

`CreditPayment`: `{id, customer, cash_session, user, branch, method, currency, amount,
approval_reference, usd_to_ves_rate, amount_usd, allocations: [{credit, amount_usd}], created_at}`.

- **La deuda se guarda y se descuenta en USD.** Un abono en VES se convierte con la **tasa del
  BCV del día del abono** (`usd_to_ves_rate`), no con la de la venta ni con una manual.
- El abono entra en la caja abierta del usuario (cuenta en su arqueo) y se aplica a las deudas
  del cliente en la sucursal de esa caja, la que vence antes primero.
- Si cubre el saldo dentro de 0,01 USD, lo salda por completo. `CREDIT` no vale como abono.

| `code` | HTTP | `meta` |
|---|---|---|
| `customer_not_found` | 404 | `customer_id` |
| `customer_tax_id_taken` | 409 | `tax_id` |
| `invalid_customer_name` | 422 | — |
| `no_pending_credit` | 409 | `customer_id`, `branch` |
| `credit_overpayment` | 422 | `balance_usd`, `balance_ves`, `paid_usd` |
| `bcv_rate_unavailable` | 503 | — (abono en VES sin tasa del BCV) |
| `no_open_session` | 409 | — |

## Estadísticas (solo MANAGER)

Todo en USD y de una sola sucursal (`branch`). **Los decimales viajan como números de JSON, no
como string**: es el único módulo que lo hace. Una venta cuenta por la fecha en que se facturó, en
la zona horaria de la tienda.

Filtros comunes (query): `branch`, `date_from` y `date_to` (`yyyy-MM-dd`, ambos incluidos; por
defecto los últimos 30 días), `category` y `subcategory` (ids).

| Método y ruta | Query adicional | Respuesta |
|---|---|---|
| `GET statistics/summary/` | — | `{period, previous_period, current, previous, change}` |
| `GET statistics/credit-breakdown/` | — | `{cash, credit, pending, credit_share}` |
| `GET statistics/groups/` | — | `{level, category_id, category_name, groups[]}` |
| `GET statistics/products/ranking/` | `order_by` (`units`, `revenue`, `profit`, `margin`; por defecto `profit`), `limit` (10; máx. 100), `min_units` (5) | `{order_by, results[]}` |
| `GET statistics/matrix/` | — | `{median_units, median_margin, counts[], products[]}` |
| `GET statistics/inventory-health/` | `no_sales_days` (30), `max_days_left` (15) | `{as_of, immobilized_capital_total, no_movement[], running_out[]}` |

- **Métricas**: ingresos = Σ `subtotal_usd`; ganancia = ingresos − Σ (cantidad × costo congelado
  en la línea); `margin` = ganancia ÷ ingresos × 100 (0 sin ingresos); `average_ticket` =
  ingresos ÷ `sales_count`.
- **`summary`**: `current` y `previous` son `{revenue, profit, margin, units, sales_count,
  average_ticket}`. `previous_period` tiene la misma duración y termina el día antes. `change` es
  la variación % de cada métrica (`null` si la anterior es 0); `change.margin` va en puntos
  porcentuales (`null` si el período anterior no tuvo ventas).
- **`credit-breakdown`**: `cash` y `credit` son `{revenue, profit, margin}` y suman los totales
  de `summary`. Una venta a crédito cuenta entera el día en que se factura; si solo una parte
  quedó como deuda, sus líneas se reparten en la proporción deuda ÷ total de la venta. `pending`
  (`{revenue, profit}`) es lo que sigue sin cobrarse **hoy** de esas ventas. `credit_share` es el
  porcentaje de los ingresos vendido a crédito.
- **`groups`**: sin `category`, `level = "category"`; con ella, `"subcategory"`. Cada grupo es
  `{id, name, units, revenue, profit, margin}`, por ganancia descendente. Los productos sin
  subcategoría forman un grupo con `id: null`.
- **`ranking`**: cada fila es `{product_id, name, unit_of_measure, category_id, category_name,
  subcategory_id, subcategory_name, units, revenue, profit, margin}`. `min_units` solo aplica al
  ordenar por margen.
- **`matrix`**: los cortes son las medianas. `quadrant`: `STAR` (unidades y margen ≥ mediana),
  `VOLUME_DRIVER` (unidades ≥, margen <), `PROFITABLE_NICHE` (unidades <, margen ≥), `REVIEW`.
- **`inventory-health`**: usa la fecha de hoy, no el período. `no_movement`: productos con stock
  sin ventas en `no_sales_days` días (`last_sale_date` nulo si nunca se vendieron), con
  `immobilized_capital` = stock × costo actual, de mayor a menor. `running_out`: productos activos
  con ventas en los últimos 30 días cuyo stock dura `max_days_left` días o menos al ritmo de esos
  30 días, de menor a mayor (`days_left`).

Errores: `invalid_period` (422), `category_not_found` / `subcategory_not_found` (404),
`subcategory_category_mismatch` (422).

## Diferencias respecto al encargo original

1. `pos_backend/CLAUDE.md` no existe: la guía está en `CLAUDE.md` de la raíz del repositorio.
2. El login fallido responde `authentication_failed`, no un código propio de usuario inactivo.
3. `auth/refresh/` devuelve solo `{access}`: el refresh no rota y vence a las 12 h del login.
4. `inventory/` no filtra ni trae datos del producto (ver limitaciones de Inventario).
5. Las ventas no traen el nombre del producto ni el del usuario; las cajas tampoco el del usuario.
6. En desarrollo (`config.settings.dev`) `ALLOWED_HOSTS` acepta cualquier host: el método
   Wi-Fi funciona en cualquier red sin tocar el backend. Producción usa `DJANGO_ALLOWED_HOSTS`.
