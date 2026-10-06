# POS multi-sucursal

Punto de venta y control de inventario para varias sucursales.

```
.
├── docker-compose.yml      # PostgreSQL 17
├── .env.example            # credenciales de la base de datos
├── pos_backend/            # backend Django + DRF
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
