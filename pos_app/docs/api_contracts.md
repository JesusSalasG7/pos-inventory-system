# Contratos de la API del backend POS

Fuente: código de `pos_backend/` y `openapi.yaml` (generado con `manage.py spectacular`) al
2026-10-06. **El backend es la fuente de verdad**: si este documento y el backend difieren, manda
el backend y este archivo se regenera.

## Convenciones generales

- **Base**: `/api/v1/`. Todas las rutas terminan en `/`.
- **Autenticación**: cabecera `Authorization: Bearer <access>`. Solo `auth/login/` y
  `auth/refresh/` son públicas.
- **Roles**: `MANAGER`, `SUPERVISOR`. "Operador" = cualquiera de los dos.
- **Decimales**: montos (2 decimales), cantidades (3) y tasas (4) llegan y se envían como
  **string decimal** (`"12.50"`, `"3.000"`, `"872.3927"`). Única excepción: `sales_count` es entero.
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
| `category` | `LIQUIDS` (Líquidos), `POWDERS` (Polvos), `ACCESSORIES` (Accesorios) |
| `unit_of_measure` | `LITER` (Litro), `KILOGRAM` (Kilogramo), `UNIT` (Unidad) |
| `movement_type` | `ENTRY` (Entrada), `SALE` (Venta), `WASTE` (Merma), `ADJUSTMENT` (Ajuste) |
| `method` | `POS_CARD` (Punto de venta), `CASH_VES` (Efectivo VES), `CASH_USD` (Efectivo USD), `MOBILE_PAYMENT` (Pago móvil) |
| `currency` | `VES` (Bolívares), `USD` (Dólares) |

Moneda obligatoria por método: `CASH_USD` → `USD`; `CASH_VES`, `POS_CARD`, `MOBILE_PAYMENT` → `VES`.

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

## Productos (catálogo global)

| Método y ruta | Permiso | Body / query | Respuesta |
|---|---|---|---|
| `GET products/` | Operador | `?active=true`, `?category=`, `?search=` (texto en el nombre) | Página de `Product`, por nombre |
| `POST products/` | MANAGER | `{name, category, unit_of_measure, cost_price_usd, sale_price_usd}` | 201 `Product` |
| `GET products/<id>/` | Operador | — | `Product` |
| `PATCH products/<id>/` | MANAGER | Cualquiera de los campos de alta | `Product` |
| `POST products/<id>/toggle-active/` | MANAGER | Sin body | `Product` |

`Product`: `{id, name, category, unit_of_measure, cost_price_usd, sale_price_usd, active}`.
**No incluye stock ni imagen.** Errores: `invalid_name` (422), `product_name_taken` (409),
`invalid_price` (422), `product_not_found` (404).

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

`ExchangeRate`: `{id, usd_to_ves_rate, created_by, created_at}`. Errores: `exchange_rate_not_set`
(409, todavía no hay tasa: no se puede facturar ni cerrar caja), `invalid_exchange_rate` (422),
`bcv_rate_unavailable` (503). La tasa BCV es solo referencia.

## Cajas

| Método y ruta | Permiso | Body / query | Respuesta |
|---|---|---|---|
| `GET cash-sessions/` | Operador | `?branch=`, `?only_open=true` | Página de `CashSession`, más reciente primero |
| `POST cash-sessions/` | Operador | `{opening_float, branch?}` | 201 `CashSession` |
| `GET cash-sessions/current/` | Operador | — | `CashSession` abierta del usuario |
| `GET cash-sessions/<id>/expenses/` | Operador | — | Página de `CashExpense` |
| `POST cash-sessions/<id>/expenses/` | Dueño o MANAGER | `{reason, amount, currency}` | 201 `CashExpense` |
| `GET cash-sessions/<id>/summary/` | Operador | — | `CashCountSummary` |
| `POST cash-sessions/<id>/close/` | Dueño o MANAGER | `{counted_amount_usd, counted_amount_ves}` | `CashSession` cerrada |

`CashSession`: `{id, user, branch, opened_at, closed_at, opening_float, counted_amount_usd,
counted_amount_ves, difference_usd}`. Abierta ⇔ `closed_at == null`. `opening_float` está en USD.
`CashExpense`: `{id, cash_session, reason, amount, currency, created_by, created_at}`.
`CashCountSummary`: `{opening_float, cash_sales_usd, cash_sales_ves, electronic_sales_usd,
electronic_sales_ves, expenses_usd, expenses_ves, expected_cash_usd, expected_cash_ves}`.

- Esperado USD = fondo + ventas efectivo USD − egresos USD. Esperado VES = ventas efectivo VES −
  egresos VES. `electronic_*` (punto y pago móvil) es informativo.
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
- **El precio nunca se envía**: sale de la base de datos. La tasa activa se congela en la venta.
- Los pagos deben cuadrar con el total dentro de 0,01 USD, **tanto si falta como si sobra**. El
  vuelto no existe en el backend: la app envía el monto exacto.
- Los pagos en VES se suman entre sí y se convierten a USD una sola vez con la tasa activa.

Respuesta 201, `Sale`:

```json
{
  "id": 41, "cash_session": 7, "user": 2, "branch": "PRINCIPAL",
  "customer_tax_id": "V12345678", "customer_name": "Ana Pérez",
  "exchange_rate_at_invoice": "150.0000", "total_usd": "15.00", "total_ves": "2250.00",
  "created_at": "2026-10-06T10:15:00-04:00",
  "details": [{"id": 90, "product": 3, "quantity": "2.500", "unit_price_usd": "6.00", "subtotal_usd": "15.00"}],
  "payments": [{"id": 77, "method": "CASH_USD", "currency": "USD", "amount": "5.00", "approval_reference": ""}]
}
```

`details[].product` es solo el id: **el nombre del producto no viene en la venta**.

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

## Diferencias respecto al encargo original

1. `pos_backend/CLAUDE.md` no existe: la guía está en `CLAUDE.md` de la raíz del repositorio.
2. El login fallido responde `authentication_failed`, no un código propio de usuario inactivo.
3. `auth/refresh/` devuelve solo `{access}`: el refresh no rota y vence a las 12 h del login.
4. `inventory/` no filtra ni trae datos del producto (ver limitaciones de Inventario).
5. Las ventas no traen el nombre del producto ni el del usuario; las cajas tampoco el del usuario.
6. `ALLOWED_HOSTS` ya se lee de `DJANGO_ALLOWED_HOSTS` en `pos_backend/.env`: no hace falta
   tocar el backend para el método Wi-Fi.
