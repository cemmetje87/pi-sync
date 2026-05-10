---
name: pi-sync
description: Secure sync for Pi settings, extensions, skills, and tools
---

# Pi Sync Extension 🔧

Securely sync all Pi configuration between machines.

## Features ✨

- Exports: skills, extensions, settings
- Excludes sensitive files (`.env`, `*_local*`)  
- Encryption: age (best) or openssl AES-256-CBC

## 📦 Installation

### NPX (Recommended) 🚀

```bash
# Install directly from npm (when published) or use npx
npx pi-sync-extension export ~/pi-backup.age
```

### From Git (Recommended for now) 

```bash
# Clone the repository
git clone https://git.ozugur.nl/foadmin/pi-sync.git
cd pi-sync

# Copy files to Pi extensions directory
mkdir -p ~/.pi/agent/extensions/pi-sync
cp sync.sh pi-sync.ts ~/.pi/agent/extensions/pi-sync/

# Create extension symlink
ln -sf ~/.pi/agent/extensions/pi-sync/pi-sync.ts ~/.pi/agent/extensions/pi-sync.ts

# Run export (generates password automatically)
cd ~/.pi/agent/extensions/pi-sync
./sync.sh export ~/pi-backup.age

# Restart Pi to load extension
```

### Quick Install (with auto-extension setup)

```bash
# Clone or download the pi-sync extension
cd ~/.pi/agent/extensions/pi-sync

# Run export with auto-install - creates extension symlink automatically
PI_SYNC_AUTO_INSTALL_EXT=1 ./sync.sh export ~/pi-backup.age
```

### Manual Install Steps

1. **📁 Download the extension**
   ```bash
   # Create directory
   mkdir -p ~/.pi/agent/extensions/pi-sync
   
   # Copy files (from repo or extract)
   # sync.sh → ~/.pi/agent/extensions/pi-sync/sync.sh
   # pi-sync.ts → ~/.pi/agent/extensions/pi-sync/pi-sync.ts
   ```

2. **🔗 Create extension symlink**
   ```bash
   ln -sf ~/.pi/agent/extensions/pi-sync/pi-sync.ts ~/.pi/agent/extensions/pi-sync.ts
   ```

3. **🔐 First run generates password**
   ```bash
   cd ~/.pi/agent/extensions/pi-sync
   ./sync.sh export ~/my-pi-config.age
   # Creates ~/pi-sync/.env with encryption password
   ```

4. **🔄 Restart Pi** to load the extension

## Usage

```bash
# Export (encrypt and save)
./sync.sh export ~/backup/pi-config.age

# Import (load and decrypt)
./sync.sh import ~/backup/pi-config.age

# Install extension for Pi (auto-creates symlink)
./sync.sh install-extension

# Auto-install extension on export
PI_SYNC_AUTO_INSTALL_EXT=1 ./sync.sh export ~/backup.pi-age
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `PI_SYNC_PASS` | Encryption password (if not set, random one generated) |
| `PI_SYNC_INSTALL_AGE` | Set to `1` to auto-install age via brew |
| `PI_SYNC_AUTO_INSTALL_EXT` | Set to `1` to auto-create extension symlink |

## What Gets Synced

- `~/.pi/agent/skills/` - All skills (excluding `.env`)
- `~/.pi/agent/extensions/` - All extensions
- `~/.pi/agent/` settings

## Security Notes

- Password stored in `~/pi-sync/.env` (NOT synced)
- Existing `.env` files in skills are excluded
- Share encrypted archive safely between machines