
#!/usr/bin/env bash
set -Eeuo pipefail

# Node1 - Discord Bot Service Creator

if [[ $EUID -ne 0 ]]; then
    echo "Requesting administrator permissions..."
    sudo -v
    exec sudo -E bash "$0" "$@"
fi

ORIGINAL_USER="${SUDO_USER:-root}"

echo
echo "======================================"
echo "       NODE1 BOT SERVICE CREATOR"
echo "======================================"
echo

read -r -p "Service name (e.g. coreservice): " SERVICE_NAME

if [[ ! "$SERVICE_NAME" =~ ^[a-zA-Z0-9_.@-]+$ ]]; then
    echo "Invalid service name."
    exit 1
fi

read -r -p "Bot project folder: " PROJECT_DIR

if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Project directory does not exist."
    exit 1
fi

PROJECT_DIR="$(realpath "$PROJECT_DIR")"

read -r -p "Linux user [$ORIGINAL_USER]: " BOT_USER
BOT_USER="${BOT_USER:-$ORIGINAL_USER}"

if ! id "$BOT_USER" >/dev/null 2>&1; then
    echo "Linux user does not exist."
    exit 1
fi

read -r -p "Startup command [pnpm start]: " START_COMMAND
START_COMMAND="${START_COMMAND:-pnpm start}"

if [[ -z "$START_COMMAND" ]]; then
    echo "Startup command cannot be empty."
    exit 1
fi

SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
RUNNER_DIR="/usr/local/lib/bot-services"
RUNNER_FILE="${RUNNER_DIR}/${SERVICE_NAME}.sh"

if [[ -e "$SERVICE_FILE" ]]; then
    echo
    read -r -p "Service already exists. Replace it? (y/N): " CONFIRM
    [[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 0

    systemctl disable --now "${SERVICE_NAME}.service" || true
fi

mkdir -p "$RUNNER_DIR"

# Safely quote values for the generated Bash runner.
printf -v QUOTED_DIR '%q' "$PROJECT_DIR"
printf -v QUOTED_COMMAND '%q' "$START_COMMAND"

cat > "$RUNNER_FILE" <<EOF
#!/usr/bin/env bash
set -Eeuo pipefail
cd -- $QUOTED_DIR
exec /bin/bash -lc $QUOTED_COMMAND
EOF

chmod 755 "$RUNNER_FILE"
chown root:root "$RUNNER_FILE"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Discord Bot - ${SERVICE_NAME}
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${BOT_USER}
WorkingDirectory=${PROJECT_DIR}
ExecStart=${RUNNER_FILE}

Restart=on-failure
RestartSec=5
TimeoutStopSec=30
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

chmod 644 "$SERVICE_FILE"

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}.service"
systemctl restart "${SERVICE_NAME}.service"

echo
echo "======================================"
echo "       SERVICE CREATED!"
echo "======================================"
echo
echo "Name:       ${SERVICE_NAME}"
echo "User:       ${BOT_USER}"
echo "Directory:  ${PROJECT_DIR}"
echo "Command:    ${START_COMMAND}"
echo
echo "Useful commands:"
echo "  sudo systemctl status ${SERVICE_NAME}"
echo "  sudo systemctl restart ${SERVICE_NAME}"
echo "  sudo systemctl stop ${SERVICE_NAME}"
echo "  sudo journalctl -u ${SERVICE_NAME} -f"
echo
