#!/usr/bin/env bash
set -euo pipefail

APP_NAME="api-auth"
APP_USER="fedora"
APP_GROUP="fedora"
APP_PORT="127.0.0.1:7878"
PROJECT_DIR="/home/fedora/dev/api-auth"
BIN_SOURCE="$PROJECT_DIR/target/release/api-auth"
BIN_TARGET="/usr/local/bin/api-auth"
ENV_SOURCE="$PROJECT_DIR/.env"
ENV_TARGET="/etc/api-auth.env"
SERVICE_TARGET="/etc/systemd/system/api-auth.service"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script with sudo."
  exit 1
fi

if [[ ! -f "$ENV_SOURCE" ]]; then
  echo "Environment file not found at $ENV_SOURCE"
  echo "Create it first, for example from .env-example"
  exit 1
fi

cd "$PROJECT_DIR"
cargo build --release

install -m 0755 "$BIN_SOURCE" "$BIN_TARGET"
install -m 0640 "$ENV_SOURCE" "$ENV_TARGET"
chown root:root "$ENV_TARGET"

cat > "$SERVICE_TARGET" <<EOF
[Unit]
Description=Eqeqo Auth API
After=network-online.target postgresql.service
Wants=network-online.target

[Service]
Type=simple
User=$APP_USER
Group=$APP_GROUP
WorkingDirectory=$PROJECT_DIR
EnvironmentFile=$ENV_TARGET
Environment=SERVER_URL=$APP_PORT
ExecStart=$BIN_TARGET
Restart=always
RestartSec=3
TimeoutStopSec=10
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now "$APP_NAME"
systemctl restart "$APP_NAME"

echo
echo "Deploy completed."
echo "Check status with:"
echo "  sudo systemctl status $APP_NAME --no-pager -l"
echo "Check logs with:"
echo "  sudo journalctl -u $APP_NAME --no-pager -n 50"
