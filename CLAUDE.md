# POS multi-sucursal — guía para trabajar en este repositorio

Backend de un Punto de Venta y Control de Inventario para un negocio con una o varias
sucursales. Django 5.2 + DRF sobre PostgreSQL, en `pos_backend/`.

## Arquitectura en capas

Cada módulo es una app Django en `pos_backend/apps/` (`auth`, `branches`, `inventory`,
`exchange_rate`, `cash_sessions`, `sales`) con esta división interna:

| Capa | Contenido | Regla |
|---|---|---|
| `api/` | `urls.py`, `views.py`, `serializers.py` | Vistas delgadas: validan entrada, llaman a un service y serializan. Sin lógica de negocio ni ORM. |
| `services/` | Reglas de negocio | Controlan las transacciones de forma explícita con `transaction.atomic()`. |
| `repositories/` | Consultas | **Única** capa que usa el ORM (`select_for_update`, `F()`, `bulk_create`). |
| `models/` | Un archivo por modelo | Re-exportados en `models/__init__.py`. |
| `domain/dtos.py` | `dataclass(frozen=True)` | Entrada de los services, cuando aplica. |

`core/` contiene lo transversal: enums, excepciones de dominio, manejador de errores, permisos,
resolución de sucursal, utilidades de dinero y paginación.

### Regla de dependencias

`views → services → repositories → models`. Nunca en sentido contrario ni saltando capas.

- Un service puede llamar a **services** de otra app, **nunca** a repositorios de otra app.
- `ATOMIC_REQUESTS = False`: la transacción la abre el service, no la petición.
- La app `apps/auth` tiene `label = "accounts"` (evita chocar con `django.contrib.auth`).
  El modelo de usuario es `accounts.User`.

## Reglas obligatorias

- **Idioma**: identificadores (carpetas, archivos, clases, funciones, variables, campos, rutas)
  estrictamente en **inglés**. Comentarios, docstrings y mensajes de commit en **español**.
- **Dinero y cantidades**: siempre `Decimal` y `DecimalField`. **Nunca `float`.** Usar las
  funciones de `core/money.py` para redondear y convertir (dinero 14,2; stock 12,3; tasa 14,4).
- **Stock**: todo cambio de stock pasa por `apps/inventory/services/stock_service.py`. Es el único
  punto que modifica `BranchInventory.current_stock` y que inserta `InventoryMovement` (Kardex).
  El Kardex es de solo inserción: los errores se corrigen con un `ADJUSTMENT`.
- **Precios**: el precio de una venta sale siempre de la base de datos, nunca del cliente.
- **Errores de negocio**: lanzar subclases de `core.exceptions.DomainError`. El manejador las
  responde como `{"code": ..., "detail": ..., "meta": {...}}`.
- **Sucursal**: las sucursales son filas de `branches.Branch`, no un enum; se crean por la API o
  el admin y nunca se borran (se desactivan). Resolverla siempre con
  `core.branch_scope.resolve_branch(user, requested_branch)`, que devuelve su `code`.
  Un SUPERVISOR solo opera en su sucursal; un MANAGER sin sucursal asignada (`assigned_branch`
  nulo) accede a todas y debe indicar cuál, salvo que solo haya una activa.
- **FK contables**: `on_delete=PROTECT`. Nada se borra: productos y usuarios se desactivan.
- Type hints en services, repositories y DTOs. Formato y lint con `ruff`.

## Comandos

Base de datos (desde la raíz del repo; usa el `.env` de la raíz):

```bash
docker compose up -d          # PostgreSQL 17 en el puerto de POSTGRES_PORT
```

Backend (desde `pos_backend/`):

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements/dev.txt
cp .env.example .env          # mismas credenciales POSTGRES_* que el .env de la raíz

python manage.py migrate
python manage.py createsuperuser
python manage.py runserver    # API en /api/v1/, documentación en /api/docs/

pytest                        # todos los tests (crea la BD test_<POSTGRES_DB>)
pytest tests/unit             # solo tests puros, sin base de datos
pytest tests/integration/test_auth.py::test_login_returns_token_pair
ruff check . && ruff format --check .
python manage.py spectacular --validate --fail-on-warn   # valida el esquema OpenAPI
```

## Estado

Todas las apps están implementadas de punta a punta: `auth` (login, refresh, `me` y gestión de
usuarios), `branches`, `exchange_rate`, `cash_sessions`, `inventory` y `sales`. No quedan stubs.

Convenciones que no se deducen a simple vista:

- La sucursal viaja entre capas como su `code` (`str`). Las FK a `Branch` usan `to_field="code"`,
  así que `obj.branch_id` es el código y `obj.branch` la instancia (evitarla: dispara una consulta).
- `branch_service` importa `stock_service` y `cash_session_service` dentro de las funciones, y
  `core.branch_scope` importa `branch_service` igual: un import a nivel de módulo crearía un ciclo.
- `InventoryMovement.quantity` guarda siempre la magnitud positiva; el sentido lo dan el tipo y
  `stock_before` / `stock_after`.
- `sale_service.create_sale` bloquea primero la caja y después el inventario (ordenado por
  `product_id`). Cualquier flujo nuevo que tome ambos bloqueos debe respetar ese orden.
- Los pagos deben cuadrar con el total dentro de `PAYMENT_TOLERANCE_USD`; el vuelto no se modela.
  `CASH_USD` se cobra en USD y el resto de métodos en VES; `POS_CARD` y `MOBILE_PAYMENT` exigen
  `approval_reference`.
- `cash_count_service` importa `sale_service` dentro de la función: `sale_service` depende de
  `cash_session_service` y un import a nivel de módulo crearía un ciclo.

`database/legacy/` guarda el esquema SQL manual anterior solo como referencia; el esquema real lo
definen las migraciones de Django.
