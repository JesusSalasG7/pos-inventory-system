# POS Sucursal — app móvil

App Flutter del POS multi-sucursal. Es el cliente del backend Django de `../pos_backend/`
y está pensada para usarse en el mostrador desde un teléfono Android.

El contrato de la API está en [`docs/api_contracts.md`](docs/api_contracts.md) y el esquema
OpenAPI en `docs/openapi.yaml`. **El backend es la fuente de verdad.**

## Requisitos

- Flutter estable (probado con 3.41.7, Dart 3.11.5).
- Android SDK con `adb` en el `PATH`.
- El backend corriendo (ver `../CLAUDE.md`): `python manage.py runserver`.

## Preparar el proyecto

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Los archivos `*.g.dart` y `*.freezed.dart` se generan: no se editan a mano.

## Ejecutar en un teléfono Android físico

Activa primero las **Opciones de desarrollador** y la **Depuración USB** en el teléfono, conéctalo
y acepta el aviso "¿Permitir depuración USB?". `adb devices` debe mostrarlo como `device`.

### Método principal: USB

```bash
scripts/run_device.sh            # Linux / macOS
scripts\run_device.ps1           # Windows (PowerShell)
```

El script ejecuta `adb reverse tcp:8000 tcp:8000`, de modo que `http://localhost:8000` en el
teléfono llega al backend del PC, y luego lanza
`flutter run --dart-define=API_BASE_URL=http://localhost:8000`.

`adb reverse` se pierde al desconectar el cable: vuelve a ejecutar el script.

### Método alternativo: Wi-Fi (misma red)

1. Averigua la IP del PC en la red local, por ejemplo `192.168.1.50`.
2. Añádela a `DJANGO_ALLOWED_HOSTS` en `pos_backend/.env`:
   `DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,192.168.1.50`
3. Arranca el backend escuchando en todas las interfaces:
   `python manage.py runserver 0.0.0.0:8000`
4. Lanza la app indicando la IP:

```bash
scripts/run_device.sh 192.168.1.50
scripts\run_device.ps1 192.168.1.50
```

El tráfico HTTP sin cifrar solo está permitido en compilaciones de depuración
(`android/app/src/debug/AndroidManifest.xml`). Una compilación release exige HTTPS.

### Otro puerto u opciones de Flutter

```bash
API_PORT=8001 scripts/run_device.sh           # el backend escucha en otro puerto
scripts/run_device.sh "" -d <device_id>       # USB, eligiendo el dispositivo
```

## Vista previa de diseño

En depuración la app abre `DesignPreviewScreen` (`/design-preview`): un catálogo de todos los
componentes globales con datos de ejemplo, sin llamar al backend. Sirve para revisar colores,
tipografía, tarjetas y estados en el teléfono.

## Tests y verificación

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze            # debe terminar sin advertencias
flutter test               # tests unitarios y de widgets
flutter build apk --debug  # debe compilar
```

El test de integración (`integration_test/`) llega en la última fase y se ejecuta en el teléfono
con `adb reverse` activo: `flutter test integration_test -d <device_id>`.
