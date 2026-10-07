# POS Tienda (app Flutter) — guía para trabajar en `pos_app/`

Cliente móvil del backend Django de `../pos_backend/`. Se usa en el mostrador, en un teléfono
Android, para tiendas de productos de limpieza en Venezuela.

## El backend es la fuente de verdad

- No se inventan rutas, campos ni formatos: se leen de `docs/api_contracts.md` y `docs/openapi.yaml`
  (regenerable con `python manage.py spectacular --file ../pos_app/docs/openapi.yaml`).
- Los totales que calcula la app son **informativos**. Tras crear una venta se muestran los que
  devuelve el backend.
- Cualquier cambio en `pos_backend/` requiere preguntar antes.

## Reglas obligatorias

- **Idioma**: identificadores (carpetas, archivos, clases, widgets, variables, rutas) en **inglés**.
  Comentarios, documentación, commits y textos de la UI en **español**.
- **Textos de la UI**: centralizados en `lib/core/l10n/strings.dart`. Ningún widget lleva textos
  sueltos. De cara al usuario una sucursal se llama **"tienda"**; en el código y en la API sigue
  siendo `branch`.
- **Dinero, cantidades y tasa**: siempre `Decimal` (paquete `decimal`). **Prohibido `double`** para
  estos valores. Se parsean desde string (`parseDecimal`) y se envían como string (`moneyToApi`,
  `quantityToApi`, `rateToApi`). Redondeo y conversión solo con `core/currency/`, que replica
  `pos_backend/core/money.py` (mitad hacia arriba; dinero 2, cantidad 3, tasa 4 decimales).
- **Tasa congelada**: las ventas pasadas (comprobante, historial, detalle) se muestran con su
  `exchange_rate_at_invoice`, pasándola a `DualCurrencyText(rate: ...)`. Solo lo "vivo" (catálogo,
  carrito, dashboard) usa la tasa activa de `activeRateProvider`.
- **Sucursal**: los repositorios envían siempre el `code` de `activeBranchProvider` en `branch`
  (query en los `GET`, body en `POST`/`PATCH`). Así un MANAGER con acceso a todas ve solo su sede.
- **Bolívares**: los precios en VES se calculan con `VesPricing` (`core/currency/`), que replica
  el redondeo hacia arriba opcional del backend. Un precio unitario se pinta con
  `DualCurrencyText(isUnitPrice: true)`; un total del carrito con `Cart.totalVes` pasado como
  `amountVes`; una venta pasada con sus propios `totalVes` / `subtotalVes`. La configuración
  (modo de tasa y redondeo) está en `pricingSettingsControllerProvider` y `roundVesUpProvider`.
- **Categorías**: las crea el gerente (`categories/`); no hay enum. La entidad es
  `ProductCategory` (`Category` choca con una clase de Flutter). Su sticker es un emoji opcional
  (`icon`); sin él, el ícono sale de una paleta fija según el `id`, y el color siempre de esa
  paleta (`CategoryStyle`). Se pintan con `CategoryAvatar` / `CategoryGlyph`. Los filtros por categoría se arman con las
  categorías de los productos cargados (`categoriesOf`).
- **Vuelto**: no existe en el backend. A la API se envía el monto exacto que cubre la venta.
- **Tasa automática**: el servidor registra sola la tasa del BCV (`source=BCV`, con su
  `effective_date`). La app vuelve a consultar la tasa al abrir, al volver a primer plano y cada
  10 minutos, y `RateChangeNoticeController` avisa cuando cambia respecto a la última vista en el
  dispositivo.
- `flutter analyze` sin advertencias. Formato con `dart format` (ancho 100).

## Arquitectura

Clean Architecture por feature, en `lib/features/<feature>/`:

| Capa | Contenido | Regla |
|---|---|---|
| `data/` | Datasource Dio, DTOs `freezed`, repositorio implementado | Única capa que conoce Dio y JSON. Convierte errores a `Failure`. |
| `domain/` | Entidades y contratos de repositorio | Dart puro: sin Flutter ni Dio. |
| `presentation/` | Providers, screens y widgets | Nunca llama a Dio directamente. |

`lib/core/` es lo transversal: `config` (entorno), `theme` (sistema de diseño), `network`
(cliente, interceptores, paginación), `errors`, `storage`, `currency`, `session`, `l10n`, `domain`
(enums y entidades compartidas) y `widgets` (componentes globales). `lib/app/` tiene el `MaterialApp`
y el router (`go_router`).

### Red y errores

- `AuthInterceptor`: agrega el Bearer; ante un 401 refresca y reintenta **una** vez; las
  peticiones concurrentes esperan un único refresco (`Completer`); si falla, borra los tokens y
  dispara `sessionExpiredProvider`. El refresh no rota: la sesión dura 12 h como máximo.
- `ErrorInterceptor`: convierte el sobre `{code, detail, meta}` en `ApiException` y distingue
  timeout, sin conexión y 5xx. `ErrorMessages` traduce cada `code` al español.
- Las pantallas reciben `Failure` (`Failure.guard` en los repositorios) y lo pintan con
  `AsyncValueView`.

### Manejo de estado: por qué Riverpod

Se usa `flutter_riverpod` con `riverpod_generator`, no BLoC ni Provider, porque:

- **Estado global derivado.** La tasa activa, la sucursal activa y la caja abierta condicionan casi
  todas las pantallas. Con Riverpod un provider observa a otro (`ref.watch`) y se recalcula solo:
  al cambiar la sucursal, inventario, caja, ventas y reportes se invalidan sin código de enlace.
  Con BLoC habría que suscribir blocs entre sí a mano.
- **Asincronía sin plantilla.** `AsyncValue` da carga, error y datos en un solo tipo, que
  `AsyncValueView` pinta igual en toda la app. BLoC exigiría eventos y estados por cada pantalla.
- **Sin `BuildContext`.** Los interceptores y repositorios leen providers fuera del árbol de
  widgets (p. ej. para avisar de la sesión vencida), algo que Provider no permite de forma limpia.
- **Tests simples.** Cualquier provider se sustituye con `overrides` en un `ProviderScope`, sin
  montar inyección de dependencias aparte.

Los reintentos automáticos de Riverpod están **desactivados** (`retry` en el `ProviderScope` de
`main.dart`): un fallo suele ser una regla de negocio del backend (409, 422…), que no se arregla
reintentando. Los tests crean sus `ProviderContainer` con el mismo `retry: (_, _) => null`.

Providers globales (`keepAlive`): `sessionControllerProvider`, `currentUserProvider`,
`activeBranchProvider`, `activeRateProvider`, `currentSessionProvider` (caja abierta), `serverOfflineProvider`, `sessionExpiredProvider`,
`dioProvider`.

### Sesión y navegación

`SessionController` (`features/auth`) orquesta el arranque: tokens → `auth/me/` → sucursales
activas → sucursal de trabajo. Su `SessionStatus` decide la pantalla, y `RouteGuards.redirect`
(función pura) lo traduce a rutas:

| Estado | Pantalla |
|---|---|
| `loading`, `error` | Splash (con reintento si falló la conexión) |
| `unauthenticated` | Login |
| `needsFirstBranch` | Crear la primera sucursal (MANAGER en un negocio sin sedes) |
| `needsBranchSelection` | Selector de sucursal (MANAGER con acceso a todas y varias sedes) |
| `branchUnavailable` | Aviso: la sucursal está inactiva o no existe ninguna |
| `ready` | Navegación principal: Inicio, Vender, Inventario, Caja y Más |

La sucursal se resuelve igual que `resolve_branch` en el backend. La última elegida por un MANAGER
se recuerda en el dispositivo. El rol y la sucursal vienen de la cuenta: nunca se eligen en el login.

## Sistema de diseño

- Estilo vivo y amigable, solo tema claro. Colores en `app_colors.dart`: verde de marca brillante,
  acento amarillo y superficie oscura (`ink`) para el carrito. **Sobre el verde de marca el texto va
  en tinta oscura (`onPrimary`), nunca en blanco**: así se cumple WCAG AA. Para texto verde sobre
  fondos claros se usa `primaryDark`.
- Formas muy redondeadas (`app_radius.dart`), botones en píldora y tarjetas con sombra suave.
- Tipografía Manrope empaquetada en `assets/fonts/` (nunca se descarga en tiempo de ejecución).
- Montos con `AppTypography.amount` (negrita y cifras tabulares). USD destacado (`$ 12,50`) y VES
  secundario (`Bs 10.904,88`), siempre con `DualCurrencyText` y `MoneyFormatter`.
- Áreas táctiles de 48 dp como mínimo; botones de acción principal de 56 dp (`PrimaryButton`).
- Vertical bloqueado en teléfonos; las tablets pueden girar y usan más columnas
  (`ProductCard.columnsFor`).
- `DesignPreviewScreen` (solo en depuración) muestra todos los componentes con datos de ejemplo.
  Se abre desde el login o desde la pestaña Más.

## Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
scripts/run_device.sh                 # teléfono por USB (adb reverse)
scripts/run_device.sh 192.168.1.50    # teléfono por Wi-Fi; la IP va en DJANGO_ALLOWED_HOSTS
flutter analyze
flutter test
flutter test test/unit/money_test.dart
flutter test integration_test/app_flow_test.dart -d <id>   # recorrido principal en el teléfono
flutter build apk --debug
```

Los tests de widgets cargan la fuente real con `test/mocks/test_fonts.dart`; sin ella Flutter usa
"Ahem" y aparecen desbordes que no existen en el dispositivo.

## Estado

Las seis fases están hechas:

1. **Base y diseño** — hecho: `core/` completo, tema, widgets globales y vista previa.
2. **Auth y sucursal** — hecho: splash, login, refresco de token, `me`, primera sucursal, selector
   y `BranchHeader` conectado.
3. **Tasa y caja** — hecho: tasa global (se refresca al volver a primer plano), pantalla de tasas
   con BCV e histórico, apertura de caja, gastos, arqueo, cierre, historial de cajas y dashboard.
   La caja abierta puede pertenecer a otra sucursal: el backend solo admite una por usuario.
4. **POS y cobro** — hecho: catálogo cruzado con el stock de la tienda, carrito, cobro con pagos
   mixtos, vuelto visual, comprobante con tasa congelada y manejo de los errores de venta.
   `CheckoutMath` (dominio puro) replica el cuadre del backend: los bolívares se suman y se
   convierten a USD una sola vez. El vuelto se descuenta del último pago en efectivo antes de
   enviar, porque el backend rechaza tanto lo que falta como lo que sobra.
5. **Inventario** — hecho: pestaña con todo el catálogo (también los productos inactivos) y su
   stock en la tienda, búsqueda, filtro por categoría y "Por reponer"; detalle de producto con
   entrada, merma y ajuste, stock en las demás tiendas y su Kardex; Kardex general de la tienda
   con filtro por tipo. Un MANAGER además crea y edita productos, los activa o desactiva y cambia
   el stock mínimo. `InventoryCatalog` concentra esas operaciones y, tras cada una, invalida todo
   lo que depende del stock (catálogo para vender, aviso de stock mínimo, Kardex). En un ajuste se
   envía el **stock contado**; si coincide con el actual el backend responde 204 y no hay
   movimiento.
6. **Más y administración** — hecho: ventas por día con su detalle (desde Inicio y desde Más),
   y para un MANAGER la administración de categorías, usuarios y tiendas. El recorrido principal
   (`test/flows/main_flow.dart`) lo comparten el test de widgets y el de integración
   (`integration_test/app_flow_test.dart`), que corre en el teléfono sin servidor.

Al cerrar una caja, la pantalla de arqueo pasa a mostrar el resultado: la diferencia definitiva
y el resumen de ventas del turno (`SessionSalesReportSection`: totales, cobros por forma de pago,
inversión, ganancia y desglose por producto). El mismo resumen aparece en el detalle de cada caja
del historial. Todo lo calcula el backend (`cash-sessions/<id>/sales-report/`).
