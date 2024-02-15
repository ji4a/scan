#!/bin/bash

DEPLOY_SCRIPT_PATH="/root/scan/bleeping.sh"
SERVICE_NAME="bleeping"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

create_service_file() {
    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Deploy Script Service
After=network.target

[Service]
User=$(whoami)
Group=$(id -gn)
WorkingDirectory=$(dirname "$DEPLOY_SCRIPT_PATH")
ExecStart=/bin/bash $DEPLOY_SCRIPT_PATH
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

enable_and_start_service() {
    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_NAME"
    sudo systemctl start "$SERVICE_NAME"
}

create_service_file
enable_and_start_service

echo "Service '$SERVICE_NAME' created and started."
