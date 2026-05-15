### File: /usr/local/bin/btrfs-fix-default.sh

#!/bin/bash
set -euo pipefail

EXPECTED_PATH="@"
LOG="/var/log/btrfs-fix-default.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

# Get current default subvolume path
CURRENT=$(btrfs subvolume get-default / | awk '{print $NF}')

if [[ "$CURRENT" == "$EXPECTED_PATH" ]]; then
    log "Btrfs default subvolume is correct ($CURRENT). Nothing to do."
    exit 0
fi

log "Btrfs default is '$CURRENT', expected '$EXPECTED_PATH'. Fixing..."

# Find ID of @ subvolume
SUBVOL_ID=$(btrfs subvolume list / | awk '/ path @$/ {print $2}')

if [[ -z "$SUBVOL_ID" ]]; then
    log "ERROR: Could not find subvolume '@'. Aborting."
    exit 1
fi

log "Setting default subvolume to ID $SUBVOL_ID (@)..."
btrfs subvolume set-default "$SUBVOL_ID" /

log "Rebuilding initramfs..."
mkinitcpio -P

log "Regenerating GRUB config..."
update-grub

log "Done. Reboot recommended."
