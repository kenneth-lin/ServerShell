```bash
#!/bin/bash

set -euo pipefail

# ============================================================
# Shadowsocks Rust installer
#
# Usage:
#   sudo bash install.sh <password> <port> <method>
#
# Example:
#   sudo bash install.sh 'MyPassword123' 8388 aes-256-gcm
#
# Supported methods depend on the installed Shadowsocks Rust
# release.
# ============================================================

INSTALL_DIR="/opt/shadowsocks-rust"
CONFIG_DIR="/etc/shadowsocks-rust"
CONFIG_FILE="${CONFIG_DIR}/config.json"
SERVICE_FILE="/etc/systemd/system/shadowsocks.service"

# ------------------------------------------------------------
# Check root
# ------------------------------------------------------------

if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: Please run this script as root."
    exit 1
fi

# ------------------------------------------------------------
# Check arguments
# ------------------------------------------------------------

if [[ $# -ne 3 ]]; then
    echo ""
    echo "Usage:"
    echo "  $0 <password> <port> <method>"
    echo ""
    echo "Example:"
    echo "  $0 'MyPassword123' 8388 aes-256-gcm"
    echo ""
    exit 1
fi

PASSWORD="$1"
PORT="$2"
METHOD="$3"

# ------------------------------------------------------------
# Validate port
# ------------------------------------------------------------

if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Port must be a number."
    exit 1
fi

if (( PORT < 1 || PORT > 65535 )); then
    echo "ERROR: Port must be between 1 and 65535."
    exit 1
fi

# ------------------------------------------------------------
# Validate password
# ------------------------------------------------------------

if [[ -z "$PASSWORD" ]]; then
    echo "ERROR: Password cannot be empty."
    exit 1
fi

# ------------------------------------------------------------
# Detect CPU architecture
# ------------------------------------------------------------

ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        TARGET="x86_64-unknown-linux-gnu"
        ;;
    aarch64)
        TARGET="aarch64-unknown-linux-gnu"
        ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "=============================================="
echo " Shadowsocks Rust Installer"
echo "=============================================="
echo ""
echo "Architecture : $ARCH"
echo "Target       : $TARGET"
echo "Port         : $PORT"
echo "Method       : $METHOD"
echo ""

# ------------------------------------------------------------
# Install dependencies
# ------------------------------------------------------------

echo "[1/7] Installing dependencies..."

dnf install -y curl tar xz gzip

# ------------------------------------------------------------
# Get latest Shadowsocks Rust release
# ------------------------------------------------------------

echo "[2/7] Detecting latest Shadowsocks Rust release..."

RELEASE_JSON="$(
    curl -fsSL \
        -H "Accept: application/vnd.github+json" \
        https://api.github.com/repos/shadowsocks/shadowsocks-rust/releases/latest
)"

VERSION="$(
    printf '%s' "$RELEASE_JSON" |
    sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' |
    head -n 1
)"

if [[ -z "$VERSION" ]]; then
    echo "ERROR: Unable to determine latest Shadowsocks Rust version."
    exit 1
fi

echo "Latest version: $VERSION"

# ------------------------------------------------------------
# Construct download URL
# ------------------------------------------------------------

PACKAGE="shadowsocks-${VERSION}.${TARGET}.tar.xz"

DOWNLOAD_URL="https://github.com/shadowsocks/shadowsocks-rust/releases/download/${VERSION}/${PACKAGE}"

echo "[3/7] Downloading:"
echo "$DOWNLOAD_URL"

TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

curl -fL \
    --retry 3 \
    --retry-delay 2 \
    "$DOWNLOAD_URL" \
    -o "${TMP_DIR}/shadowsocks.tar.xz"

# ------------------------------------------------------------
# Extract
# ------------------------------------------------------------

echo "[4/7] Installing Shadowsocks Rust..."

mkdir -p "$INSTALL_DIR"

tar -xJf \
    "${TMP_DIR}/shadowsocks.tar.xz" \
    -C "$TMP_DIR"

if [[ ! -f "${TMP_DIR}/ssserver" ]]; then
    echo "ERROR: ssserver was not found in the downloaded archive."
    exit 1
fi

install -m 0755 \
    "${TMP_DIR}/ssserver" \
    "${INSTALL_DIR}/ssserver"

# ------------------------------------------------------------
# Create configuration
# ------------------------------------------------------------

echo "[5/7] Creating configuration..."

mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" <<EOF
{
    "server": "0.0.0.0",
    "server_port": ${PORT},
    "password": "${PASSWORD}",
    "method": "${METHOD}",
    "mode": "tcp_and_udp"
}
EOF

chmod 600 "$CONFIG_FILE"

# ------------------------------------------------------------
# Create systemd service
# ------------------------------------------------------------

echo "[6/7] Creating systemd service..."

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Shadowsocks Rust Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=${INSTALL_DIR}/ssserver -c ${CONFIG_FILE}
Restart=on-failure
RestartSec=3

NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# ------------------------------------------------------------
# Enable and start
# ------------------------------------------------------------

echo "[7/7] Starting Shadowsocks..."

systemctl daemon-reload
systemctl enable shadowsocks.service
systemctl restart shadowsocks.service

sleep 2

# ------------------------------------------------------------
# Check status
# ------------------------------------------------------------

if systemctl is-active --quiet shadowsocks.service; then

    echo ""
    echo "=============================================="
    echo " Shadowsocks installation completed"
    echo "=============================================="
    echo ""
    echo "Version  : ${VERSION}"
    echo "Arch     : ${TARGET}"
    echo "Port     : ${PORT}"
    echo "Method   : ${METHOD}"
    echo "Password : ${PASSWORD}"
    echo ""
    echo "Config:"
    echo "  ${CONFIG_FILE}"
    echo ""
    echo "Service:"
    echo "  systemctl status shadowsocks"
    echo ""
    echo "Logs:"
    echo "  journalctl -u shadowsocks -f"
    echo ""
    echo "IMPORTANT:"
    echo "Open TCP and UDP port ${PORT} in AWS Lightsail Networking."
    echo ""

else

    echo ""
    echo "ERROR: Shadowsocks failed to start."
    echo ""
    systemctl status shadowsocks.service --no-pager || true
    echo ""
    journalctl -u shadowsocks.service --no-pager -n 50 || true
    exit 1

fi
```
