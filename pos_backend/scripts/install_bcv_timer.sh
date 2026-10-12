#!/usr/bin/env bash
# Instala un temporizador de systemd (de usuario) que sincroniza la tasa del BCV
# todos los días a las 7:00, hora de Caracas, con una segunda comprobación a las
# 9:00 por si a las 7:00 la fuente (DolarApi) todavía no había publicado la tasa nueva.
#
#   scripts/install_bcv_timer.sh             instala o actualiza el temporizador
#   scripts/install_bcv_timer.sh --uninstall lo desactiva y borra
#
# El comando `sync_bcv_rate` solo registra la tasa si el negocio está en modo BCV
# y el BCV publicó una distinta; en modo MANUAL no hace nada.
#
# `Persistent=true`: si el PC estaba apagado a esa hora, se ejecuta al encenderlo.
# Si falla (sin red o sin base de datos), se reintenta cada 10 minutos, hasta 6 veces.
set -euo pipefail

BACKEND_DIR="$(cd "$(dirname "$0")/.." && pwd)"
UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
NAME="pos-bcv-sync"

if [[ "${1:-}" == "--uninstall" ]]; then
  systemctl --user disable --now "${NAME}.timer" 2>/dev/null || true
  rm -f "${UNIT_DIR}/${NAME}.service" "${UNIT_DIR}/${NAME}.timer"
  systemctl --user daemon-reload
  echo "Temporizador ${NAME} eliminado."
  exit 0
fi

if [[ ! -x "${BACKEND_DIR}/.venv/bin/python" ]]; then
  echo "No existe ${BACKEND_DIR}/.venv: crea el entorno virtual antes." >&2
  exit 1
fi

mkdir -p "$UNIT_DIR"

cat > "${UNIT_DIR}/${NAME}.service" <<UNIT
[Unit]
Description=POS: sincroniza la tasa del BCV
After=network-online.target
StartLimitIntervalSec=2h
StartLimitBurst=6

[Service]
Type=oneshot
WorkingDirectory=${BACKEND_DIR}
ExecStart=${BACKEND_DIR}/.venv/bin/python manage.py sync_bcv_rate
Restart=on-failure
RestartSec=10min
UNIT

cat > "${UNIT_DIR}/${NAME}.timer" <<UNIT
[Unit]
Description=POS: tasa del BCV todos los días a las 7:00 y a las 9:00

[Timer]
OnCalendar=*-*-* 07:00:00 America/Caracas
OnCalendar=*-*-* 09:00:00 America/Caracas
Persistent=true

[Install]
WantedBy=timers.target
UNIT

systemctl --user daemon-reload
systemctl --user enable --now "${NAME}.timer"

echo "Temporizador instalado. Próxima ejecución:"
systemctl --user list-timers "${NAME}.timer" --no-pager
echo
echo "Ver el resultado de las ejecuciones:  journalctl --user -u ${NAME}.service"
echo "Ejecutarlo ahora mismo:               systemctl --user start ${NAME}.service"
