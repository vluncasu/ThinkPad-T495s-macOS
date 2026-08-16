#!/bin/zsh
set -uo pipefail

# Transfers EFI from this repository to the internal disk's EFI partition.
# Run this AFTER macOS is installed and booted from USB.

ROOT="${0:A:h}"
EFI_SOURCE="$ROOT/../EFI"

if [[ ! -d "$EFI_SOURCE" ]]; then
  echo "ERROR: EFI folder not found at $EFI_SOURCE"
  echo "Make sure you run this from inside the downloaded release folder."
  exit 1
fi

echo ""
echo "======================================"
echo "  Transfer EFI to Internal Disk"
echo "======================================"
echo ""

# Find internal disk (first internal NVMe/SATA with an EFI partition)
INTERNAL_DISK=""
for disk in $(diskutil list -plist internal physical 2>/dev/null | plutil -extract AllDisks json -o - - 2>/dev/null | tr -d '[]"' | tr ',' '\n'); do
  if diskutil info "$disk" 2>/dev/null | grep -q "EFI"; then
    INTERNAL_DISK="$disk"
    break
  fi
done

# Fallback: look for EFI partition on disk0
if [[ -z "$INTERNAL_DISK" ]]; then
  if diskutil list disk0 2>/dev/null | grep -qi "EFI"; then
    INTERNAL_DISK="disk0s1"
  fi
fi

if [[ -z "$INTERNAL_DISK" ]]; then
  echo "Could not auto-detect internal EFI partition."
  echo ""
  echo "Available disks:"
  diskutil list | grep -E "(disk[0-9]|EFI)"
  echo ""
  printf "Enter EFI partition identifier (e.g. disk0s1): "
  read INTERNAL_DISK
fi

if [[ -z "$INTERNAL_DISK" ]]; then
  echo "ERROR: No partition specified. Aborting."
  exit 1
fi

echo "Target EFI partition: $INTERNAL_DISK"
echo ""

# Mount EFI partition
MOUNT_POINT="/Volumes/EFI_INTERNAL_$$"
mkdir -p "$MOUNT_POINT" 2>/dev/null || true

echo "Mounting $INTERNAL_DISK..."
sudo diskutil mount -mountPoint "$MOUNT_POINT" "$INTERNAL_DISK"

if [[ ! -d "$MOUNT_POINT" ]]; then
  echo "ERROR: Failed to mount $INTERNAL_DISK"
  exit 1
fi

# Backup existing EFI if present
if [[ -d "$MOUNT_POINT/EFI" ]]; then
  BACKUP="$MOUNT_POINT/EFI-backup-$(date +%Y%m%d-%H%M%S)"
  echo "Existing EFI found — backing up to $(basename "$BACKUP")"
  sudo mv "$MOUNT_POINT/EFI" "$BACKUP"
fi

# Copy EFI
echo "Copying EFI..."
sudo cp -R "$EFI_SOURCE" "$MOUNT_POINT/EFI"
sudo chown -R 0:0 "$MOUNT_POINT/EFI"

# Verify
if [[ -f "$MOUNT_POINT/EFI/OC/config.plist" ]]; then
  echo ""
  echo "======================================"
  echo "  EFI transferred successfully"
  echo "======================================"
  echo ""
  echo "  From: $EFI_SOURCE"
  echo "  To:   $MOUNT_POINT/EFI"
  echo ""
  echo "  IMPORTANT: Generate your own SMBIOS!"
  echo "  The config has FAKE serial numbers."
  echo "  Use GenSMBIOS with model MacBookPro16,3"
  echo "  then edit $MOUNT_POINT/EFI/OC/config.plist"
  echo ""
  echo "  After that, remove the USB and reboot."
  echo "  The laptop will boot macOS from internal disk."
  echo ""
else
  echo "ERROR: Transfer may have failed — config.plist not found at destination"
  exit 1
fi
