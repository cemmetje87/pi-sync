# Pi Sync Extension

Securely sync Pi configuration (settings, extensions, skills, tools) between machines.

## Features
- Export/import all Pi configuration to/from encrypted archive
- Excludes sensitive files (`.env`, `*_local*`)  
- Encryption: age (best) or openssl AES-256-CBC

## Usage
```bash
# Export (encrypt and save)
./sync.sh export ~/backup/pi-config.age

# Import (load and decrypt)
./sync.sh import ~/backup/pi-config.age

# Auto-install extension on export
PI_SYNC_AUTO_INSTALL_EXT=1 ./sync.sh export ~/backup.pi-age
```

## Environment Variables
| Variable | Description |
|----------|-------------|
| `PI_SYNC_PASS` | Encryption password (if not set, random one generated) |
| `PI_SYNC_INSTALL_AGE` | Set to `1` to auto-install age via brew |
| `PI_SYNC_AUTO_INSTALL_EXT` | Set to `1` to auto-create extension symlink |