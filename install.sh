#!/usr/bin/env bash
set -euo pipefail

# pi-sync One-Liner Installer
# Usage: curl -fsSL https://git.ozugur.nl/foadmin/pi-sync/raw/branch/main/install.sh | bash

APP="pi-sync"
REPO_URL="https://git.ozugur.nl/foadmin/pi-sync"
INSTALL_DIR="$HOME/.pi/agent/extensions/pi-sync"

MUTED='\033[0;2m'
GREEN='\033[0;32m'
ORANGE='\033[38;5;214m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${ORANGE}⚠${NC} $1"; }

usage() {
    cat <<EOF
pi-sync Installer

Usage: curl -fsSL https://git.ozugur.nl/foadmin/pi-sync/raw/branch/main/install.sh | bash [options]

Options:
    -h, --help              Display this help message
    -e, --export <file>     Run export after install (saves to specified file)
EOF
}

EXPORT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -e|--export) EXPORT_FILE="$2"; shift 2 ;;
        *) shift ;;
    esac
done

echo -e "${MUTED}Installing ${APP}...${NC}"

# Create directory
mkdir -p "$INSTALL_DIR"

# Download files
curl -fsSL "${REPO_URL}/raw/branch/main/sync.sh" -o "${INSTALL_DIR}/sync.sh"
curl -fsSL "${REPO_URL}/raw/branch/main/pi-sync.ts" -o "${INSTALL_DIR}/pi-sync.ts"
chmod +x "${INSTALL_DIR}/sync.sh"

log_info "Extension files installed to ${INSTALL_DIR}"

# Create symlink
ln -sf "${INSTALL_DIR}/pi-sync.ts" "$HOME/.pi/agent/extensions/pi-sync.ts"
log_info "Extension symlink created"

# Run export if requested
if [[ -n "$EXPORT_FILE" ]]; then
    log_info "Running initial export..."
    PI_SYNC_AUTO_INSTALL_EXT=1 "${INSTALL_DIR}/sync.sh" export "$EXPORT_FILE"
    log_info "Exported to ${EXPORT_FILE}"
fi

log_info "Installation complete! Restart Pi to load the extension."