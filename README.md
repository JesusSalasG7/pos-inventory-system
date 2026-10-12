# POS multi-sucursal

Punto de venta y control de inventario para varias sucursales.

```
.
├── docker-compose.yml      # PostgreSQL 17
├── .env.example            # credenciales de la base de datos
├── pos_backend/            # backend Django + DRF
├── pos_app/                # app móvil Flutter
├── database/legacy/        # esquema SQL manual anterior (solo referencia)
└── CLAUDE.md               # arquitectura, reglas y comandos
```

## Puesta en marcha

```bash
cp .env.example .env                      # definir POSTGRES_PASSWORD
docker compose up -d                      # la base arranca vacía

cd pos_backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements/dev.txt
cp .env.example .env                      # mismas credenciales POSTGRES_*
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

- API: `http://localhost:8000/api/v1/`
- Documentación (Swagger): `http://localhost:8000/api/docs/`
- Admin: `http://localhost:8000/admin/`

El esquema de la base de datos lo gestionan las migraciones de Django. La arquitectura en capas,
las reglas del proyecto y el resto de comandos están en [CLAUDE.md](CLAUDE.md).

## Arranque diario (backend + app en el teléfono por Wi-Fi)

Una vez hecha la puesta en marcha, cada vez que vayas a trabajar:

1. **Base de datos**, solo si está apagada (por ejemplo, tras reiniciar el PC). Desde la raíz:

   ```bash
   docker compose up -d
   ```

2. **Backend**, siempre. Escucha en todas las interfaces para que el teléfono llegue a él:

   ```bash
   cd pos_backend && source .venv/bin/activate
   python manage.py runserver 0.0.0.0:8000
   ```

3. **App**, solo si vas a cambiar código (hot reload) o si cambió la IP del PC. Si solo quieres
   usarla, abre en el teléfono la app ya instalada mientras el backend esté corriendo.

   ```bash
   cd pos_app
   scripts/run_device.sh 192.168.1.123   # IP actual del PC en la red Wi-Fi
   ```

La IP del PC puede cambiar al conectarte a otra red Wi-Fi o al reconectarte a la misma. Si la
app no conecta, consúltala y vuelve a ejecutar el paso 3 con la nueva:

```bash
ip -4 addr show | grep 192.168
```

En desarrollo el backend acepta cualquier host, así que no hay que tocar `pos_backend/.env` al
cambiar de red. El teléfono debe estar en la misma Wi-Fi, y una VPN activa en el PC puede
bloquear el acceso desde la red local. Con el teléfono conectado por USB, usa
`scripts/run_device.sh` sin IP. Más detalles en [pos_app/README.md](pos_app/README.md).

## Tasa automática del BCV

La tasa activa se sincroniza con la tasa oficial del BCV mediante un comando:

```bash
cd pos_backend && source .venv/bin/activate
python manage.py sync_bcv_rate
```

Registra una tasa nueva solo cuando el BCV publica una distinta; si no cambió, no hace nada.
Una tasa registrada a mano por un gerente vale hasta la siguiente publicación del BCV.

Solo actúa si el negocio vende con la tasa del BCV (modo BCV). En modo manual no hace nada.

Para que se ejecute sola todos los días a las 7:00 (hora de Caracas), con una segunda comprobación
a las 9:00 por si a las 7:00 la fuente aún no tenía la tasa nueva, instala el temporizador de
systemd una sola vez:

```bash
cd pos_backend
scripts/install_bcv_timer.sh              # instala o actualiza
scripts/install_bcv_timer.sh --uninstall  # lo elimina
```

- Si el PC estaba apagado a esa hora, se ejecuta al encenderlo.
- Si falla (sin internet o con la base de datos apagada), reintenta cada 10 minutos, hasta 6 veces.
- Es un temporizador de usuario: corre mientras tu sesión esté iniciada. Para que corra aunque no
  inicies sesión, ejecuta `sudo loginctl enable-linger $USER`.

```bash
systemctl --user list-timers pos-bcv-sync.timer   # próxima ejecución
journalctl --user -u pos-bcv-sync.service         # resultado de las ejecuciones
systemctl --user start pos-bcv-sync.service       # ejecutarlo ahora
```

Si mueves el repositorio de carpeta, vuelve a ejecutar `scripts/install_bcv_timer.sh`.

Un gerente también puede forzar la sincronización desde la app (Más → Tasa de cambio).
