#!/usr/bin/env bash
set -euo pipefail

# pi-sync One-Liner Installer
# Usage: curl -fsSL https://github.com/cemmetje87/pi-sync/raw/main/install.sh | bash

APP="pi-sync"
REPO_URL="https://github.com/cemmetje87/pi-sync"
INSTALL_DIR="$HOME/.pi/agent/extensions/pi-sync"
PKG_NAME="pi-sync-extension"

MUTED='\033[0;2m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
ORANGE='\033[38;5;214m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}✓${NC} $1"; }
log_warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

usage() {
    cat <<EOF
pi-sync Installer

Usage: curl -fsSL https://github.com/cemmetje87/pi-sync/raw/main/install.sh | bash [options]

Options:
    -h, --help              Display this help message
    --force                 Force legacy symlink install even if npm package exists
    -e, --export <file>     Run export after install (saves to specified file)
EOF
}

# Check if already installed via pi packages (npm)
is_pi_package_installed() {
    local settings="$HOME/.pi/agent/settings.json"
    if [[ -f "$settings" ]]; then
        grep -q "${PKG_NAME}" "$settings" 2>/dev/null
    else
        return 1
    fi
}

FORCE=false
EXPORT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)   usage; exit 0 ;;
        --force)     FORCE=true; shift ;;
        -e|--export) EXPORT_FILE="$2"; shift 2 ;;
        *)           shift ;;
    esac
done

# Guard: if pi-sync-extension already installed as pi package, skip legacy install
if is_pi_package_installed && [[ "$FORCE" != "true" ]]; then
    log_warn "pi-sync already installed as pi package (${PKG_NAME} in settings.json)."
    echo ""
    echo "  Legacy symlink install would create a tool name conflict."
    echo "  The npm package provides the extension — no symlink needed."
    echo ""
    echo "  To update:  npm update -g ${PKG_NAME}"
    echo "  To force legacy install anyway: curl ... | bash -s -- --force"

    # Still set up sync.sh + .env for CLI use if not already present
    if [[ ! -d "$INSTALL_DIR" ]] || [[ ! -f "$INSTALL_DIR/sync.sh" ]]; then
        echo ""
        log_info "Installing sync.sh for CLI use (no extension symlink)..."
        mkdir -p "$INSTALL_DIR"
        curl -fsSL "${REPO_URL}/raw/main/sync.sh" -o "${INSTALL_DIR}/sync.sh"
        chmod +x "${INSTALL_DIR}/sync.sh"

        # Initialize encryption if needed
        if [[ ! -f "$HOME/pi-sync/.env" ]]; then
            "${INSTALL_DIR}/sync.sh" export /dev/null 2>/dev/null || true
        fi
    fi
    exit 0
fi

echo -e "${MUTED}Installing ${APP}...${NC}"

# Create directory
mkdir -p "$INSTALL_DIR"

# Download files
curl -fsSL "${REPO_URL}/raw/main/sync.sh" -o "${INSTALL_DIR}/sync.sh"
curl -fsSL "${REPO_URL}/raw/main/pi-sync.ts" -o "${INSTALL_DIR}/pi-sync.ts"
chmod +x "${INSTALL_DIR}/sync.sh"

log_info "Extension files installed to ${INSTALL_DIR}"

# Create symlink (legacy — conflicts if npm package also installed)
ln -sf "${INSTALL_DIR}/pi-sync.ts" "$HOME/.pi/agent/extensions/pi-sync.ts"
log_info "Extension symlink created"
log_warn "Consider using 'pi install pi-sync-extension' instead to avoid conflicts."

# Run export if requested
if [[ -n "$EXPORT_FILE" ]]; then
    log_info "Running initial export..."
    PI_SYNC_AUTO_INSTALL_EXT=1 "${INSTALL_DIR}/sync.sh" export "$EXPORT_FILE"
    log_info "Exported to ${EXPORT_FILE}"
fi

log_info "Installation complete! Restart Pi to load the extension."