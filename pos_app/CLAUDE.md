# POS Sucursal (app Flutter) — guía para trabajar en `pos_app/`

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
  sueltos.
- **Dinero, cantidades y tasa**: siempre `Decimal` (paquete `decimal`). **Prohibido `double`** para
  estos valores. Se parsean desde string (`parseDecimal`) y se envían como string (`moneyToApi`,
  `quantityToApi`, `rateToApi`). Redondeo y conversión solo con `core/currency/`, que replica
  `pos_backend/core/money.py` (mitad hacia arriba; dinero 2, cantidad 3, tasa 4 decimales).
- **Tasa congelada**: las ventas pasadas (comprobante, historial, detalle) se muestran con su
  `exchange_rate_at_invoice`, pasándola a `DualCurrencyText(rate: ...)`. Solo lo "vivo" (catálogo,
  carrito, dashboard) usa la tasa activa de `activeRateProvider`.
- **Sucursal**: los repositorios envían siempre el `code` de `activeBranchProvider` en `branch`
  (query en los `GET`, body en `POST`/`PATCH`). Así un MANAGER con acceso a todas ve solo su sede.
- **Vuelto**: no existe en el backend. A la API se envía el monto exacto que cubre la venta.
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

Providers globales (`keepAlive`): `currentUserProvider`, `activeBranchProvider`,
`activeRateProvider`, `serverOfflineProvider`, `sessionExpiredProvider`, `dioProvider`.

## Sistema de diseño

- Solo tema claro. Colores en `app_colors.dart` (contraste WCAG AA), tipografía Manrope empaquetada
  en `assets/fonts/` (nunca se descarga en tiempo de ejecución).
- Montos con `AppTypography.amount` (negrita y cifras tabulares). USD destacado (`$ 12,50`) y VES
  secundario (`Bs 10.904,88`), siempre con `DualCurrencyText` y `MoneyFormatter`.
- Áreas táctiles de 48 dp como mínimo; botones de acción principal de 56 dp (`PrimaryButton`).
- Vertical bloqueado en teléfonos; las tablets pueden girar y usan más columnas
  (`ProductCard.columnsFor`).
- `DesignPreviewScreen` (solo en depuración) muestra todos los componentes con datos de ejemplo.

## Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
scripts/run_device.sh                 # teléfono por USB (adb reverse)
scripts/run_device.sh 192.168.1.50    # teléfono por Wi-Fi; la IP va en DJANGO_ALLOWED_HOSTS
flutter analyze
flutter test
flutter test test/unit/money_test.dart
flutter build apk --debug
```

Los tests de widgets cargan la fuente real con `test/mocks/test_fonts.dart`; sin ella Flutter usa
"Ahem" y aparecen desbordes que no existen en el dispositivo.

## Estado

Desarrollo por fases, con pausa y aprobación entre cada una:

1. **Base y diseño** — hecho: `core/` completo, tema, widgets globales y vista previa.
2. Auth y sucursal.
3. Tasa y caja.
4. POS y cobro.
5. Inventario.
6. Más y administración, y test de integración en el teléfono.
