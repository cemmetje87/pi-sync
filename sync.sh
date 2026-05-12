#!/usr/bin/env bash
# Pi Sync - Secure export/import of Pi configuration

set -e

COMMAND="$1"
TARGET="$2"

PI_DIR="$HOME/.pi"
AGENT_DIR="$PI_DIR/agent"
SYNC_DIR="$HOME/pi-sync"
ENV_FILE="$SYNC_DIR/.env"

# Check if pi is installed
has_pi() { [[ -d "$PI_DIR" ]]; }

# Check if pi-sync already installed via pi packages (npm)
is_pi_package_installed() {
    local settings="$PI_DIR/agent/settings.json"
    if [[ -f "$settings" ]]; then
        grep -q "pi-sync-extension" "$settings" 2>/dev/null
    else
        return 1
    fi
}

# Install extension for Pi (legacy: only when not already a pi package)
install_extension() {
    if is_pi_package_installed; then
        echo "pi-sync already installed as pi package (npm). Skipping legacy symlink."
        return 0
    fi

    echo "Installing pi-sync extension for Pi..."
    
    local ext_link="$PI_DIR/agent/extensions/pi-sync.ts"
    if [[ -L "$ext_link" ]]; then
        echo "Extension already linked: $ext_link"
    else
        ln -sf "$SYNC_DIR/pi-sync.ts" "$ext_link"
        echo "Created extension link: $ext_link"
    fi
    
    echo "Restart Pi to load the extension."
}

# Initialize sync directory
init_sync() {
    mkdir -p "$SYNC_DIR"
    
    if [[ ! -f "$ENV_FILE" ]]; then
        # Non-interactive mode: offer to install age
        if command -v brew &>/dev/null && [[ "${PI_SYNC_INSTALL_AGE:-0}" == "1" ]]; then
            echo "Installing age..."
            brew install age 2>/dev/null || true
        fi
        
        # Set up password
        if [[ -n "${PI_SYNC_PASS}" ]]; then
            echo "PI_SYNC_PASS=$PI_SYNC_PASS" > "$ENV_FILE"
        else
            # Generate random password
            PASSWORD=$(openssl rand -hex 16 2>/dev/null || head -c 16 /dev/urandom | xxd -p)
            echo "PI_SYNC_PASS=$PASSWORD" > "$ENV_FILE"
            echo "Generated encryption password: $PASSWORD"
            echo "Saved to: $ENV_FILE"
        fi
    else
        echo "Using existing $ENV_FILE"
    fi
    
    # Load password
    set -a
    source "$ENV_FILE" 2>/dev/null || true
    set +a
}

# Auto-offer extension install if pi detected (non-interactive mode)
if has_pi && [[ "${PI_SYNC_AUTO_INSTALL_EXT:-0}" == "1" ]]; then
    install_extension
fi

# Check for encryption tools
has_age() { command -v age &>/dev/null && [[ -f ~/.ssh/id_age ]]; }
has_openssl() { command -v openssl &>/dev/null; }

encrypt_file() {
    local input="$1" output="$2"
    
    if has_age; then
        age -e -i ~/.ssh/id_age > "$output" < "$input"
    elif has_openssl; then
        openssl enc -aes-256-cbc -pbkdf2 -in "$input" -out "$output" -k "${PI_SYNC_PASS:-changeme}"
    else
        cp "$input" "$output"
        echo "WARNING: No encryption tool found, data unencrypted!" >&2
    fi
}

decrypt_file() {
    local input="$1" output="$2"
    
    if has_age; then
        age -d -i ~/.ssh/id_age < "$input" > "$output"
    elif has_openssl; then
        openssl enc -d -aes-256-cbc -pbkdf2 -in "$input" -out "$output" -k "${PI_SYNC_PASS:-changeme}"
    else
        cp "$input" "$output"
    fi
}

export_all() {
    local target="$1"
    
    echo "Exporting Pi configuration..."
    
    local temp=$(mktemp -d)
    tar -czf "$temp/pi-backup.tar.gz" \
        -C "$AGENT_DIR" \
        --exclude='*.env' \
        --exclude='*_local*' \
        --exclude='*.age' \
        --exclude='pi-sync*' \
        . 2>/dev/null || true
    
    encrypt_file "$temp/pi-backup.tar.gz" "$target"
    
    rm -rf "$temp"
    echo "Exported to: $target"
}

import_all() {
    local source="$1"
    
    echo "Importing Pi configuration..."
    
    local temp=$(mktemp -d)
    
    decrypt_file "$source" "$temp/pi-backup.tar.gz"
    
    tar -xzf "$temp/pi-backup.tar.gz" -C "$AGENT_DIR"
    
    rm -rf "$temp"
    echo "Imported from: $source"
}

# Initialize on any command
init_sync

case "$COMMAND" in
    export) export_all "$TARGET" ;;
    import) import_all "$TARGET" ;;
    install-extension) install_extension ;;
    *) 
        echo "Usage: $0 {export|import|install-extension} <file>"
        exit 1 ;;
esac
