#!/usr/bin/env bash
# Ejecuta la app en un teléfono Android físico.
#
#   scripts/run_device.sh              USB: redirige el puerto con adb reverse
#   scripts/run_device.sh 192.168.1.50 Wi-Fi: usa la IP del PC en la red local
#
# Los argumentos a partir del segundo se pasan tal cual a `flutter run`.
set -euo pipefail

cd "$(dirname "$0")/.."
PORT="${API_PORT:-8000}"
LAN_IP="${1:-}"

if [[ -n "$LAN_IP" ]]; then
  shift
  API_BASE_URL="http://${LAN_IP}:${PORT}"
  echo "Modo Wi-Fi: el backend debe correr con 'runserver 0.0.0.0:${PORT}'"
  echo "y ${LAN_IP} debe estar en DJANGO_ALLOWED_HOSTS de pos_backend/.env"
else
  adb reverse "tcp:${PORT}" "tcp:${PORT}"
  API_BASE_URL="http://localhost:${PORT}"
  echo "Modo USB: adb reverse activo en el puerto ${PORT}"
fi

echo "API_BASE_URL=${API_BASE_URL}"
exec flutter run --dart-define="API_BASE_URL=${API_BASE_URL}" "$@"
