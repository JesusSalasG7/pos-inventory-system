"""Configuración de desarrollo local."""

from .base import *  # noqa: F403

DEBUG = True

# En desarrollo se acepta cualquier host: la IP del PC cambia con cada red Wi-Fi y el
# teléfono llega al backend por ella. Producción sigue usando DJANGO_ALLOWED_HOSTS.
ALLOWED_HOSTS = ["*"]
