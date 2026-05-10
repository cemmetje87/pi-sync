---
name: pi-sync
description: Secure sync for Pi settings, extensions, skills, and tools
---

# Pi Sync Extension

Securely sync all Pi configuration between machines.

## Features

- Exports: skills, extensions, settings
- Excludes sensitive files (`.env`, `*_local*`)
- Encryption: age (best) or openssl AES-256-CBC

## Setup

On first run, creates `~/pi-sync/.env` with encryption password:
- To install age: `PI_SYNC_INSTALL_AGE=1 ./sync.sh export ...`
- To set custom password: `PI_SYNC_PASS=yourpass ./sync.sh export ...`

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