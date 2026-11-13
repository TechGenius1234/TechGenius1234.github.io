#!/usr/bin/env bash
set -Eeuo pipefail

URL="https://techgenius1234.github.io/servicemaker.sh"
TARGET="/tmp/servicemaker.sh"

echo "======================================"
echo "       NODE1 SERVICEMAKER LAUNCHER"
echo "======================================"

if [[ -f "$TARGET" ]]; then
    echo "[OK] Existing ServiceMaker found."
    echo "[OK] Using local copy."
else
    echo "[INFO] ServiceMaker not found."
    echo "[INFO] Downloading..."

    if ! command -v curl >/dev/null 2>&1; then
        echo "[ERROR] curl is not installed."
        exit 1
    fi

    curl -fsSL "$URL" -o "$TARGET"
    echo "[OK] Download complete."
fi

if [[ ! -s "$TARGET" ]]; then
    echo "[ERROR] ServiceMaker file is empty."
    exit 1
fi

echo "[INFO] Starting ServiceMaker..."
sudo bash "$TARGET" </dev/tty

