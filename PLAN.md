# Plan: Pi Sync Extension

## Context
User wants to sync Pi configuration (settings, extensions, skills, tools) between machines securely. Need encrypted export/import solution.

## Approach
Create a pi-sync extension that exports/imports all Pi configuration to/from an encrypted archive.

## Files to Modify
- Create `/home/cozugur/.pi/agent/extensions/pi-sync/` (new extension)

## Reuse
- Existing extension pattern from other `.ts` files in `~/.pi/agent/extensions/`
- bash scripting pattern from other skill scripts

## Steps
- [x] Create pi-sync extension directory structure
- [x] Write sync.sh script with export/import functionality
- [x] Write TypeScript extension entry point (pi-sync.ts)
- [x] Document usage in SKILL.md
- [x] Test with actual configuration
- [x] Add Pi detection + auto-extension install (`PI_SYNC_AUTO_INSTALL_EXT=1`)

## Encryption Method
- Primary: age encryption (if `~/.ssh/id_age` exists)
- Fallback: openssl AES-256-CBC with PBKDF2
- Password: `PI_SYNC_PASS` from `~/pi-sync/.env`

## Install Behavior
- On first run: Create `~/pi-sync/.env` if missing
- Auto-detect if Pi is installed (`~/.pi` directory exists)
- If Pi detected and `PI_SYNC_AUTO_INSTALL_EXT=1`: auto-install extension by creating symlink
- Ask user: "Install age for better encryption? (requires brew)" 
  - If yes: run `brew install age` if brew exists
  - If no or brew unavailable: use openssl fallback
- Ask user: "Set password now, or edit ~/pi-sync/.env manually later?"
  - If now: prompt for password
  - If later: generate random password
- Never overwrite existing `~/pi-sync/.env`
- Notify user if `~/pi-sync/.env` already exists during install

## New: Extension Auto-Install
- `PI_SYNC_AUTO_INSTALL_EXT=1 ./sync.sh export ...` - auto-creates symlink at `~/.pi/agent/extensions/pi-sync.ts`
- Detects Pi installation and offers to install extension

## Verification
- [x] Test export creates encrypted archive (~4MB+)
- [x] Verify .env files are excluded from export
- [x] Extension loads without errors (fixed factory function pattern)