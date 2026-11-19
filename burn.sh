#!/usr/bin/env bash
# Burn the Xbox 360 backwards compatibility update ISO to a blank CD-R / DVD-R (macOS).
# Usage: ./burn.sh [path/to/image.iso]
set -euo pipefail

ISO="${1:-$(dirname "$0")/Xbox360_BC_Update_Nov2007.iso}"
[ -f "$ISO" ] || { echo "ISO not found: $ISO" >&2; exit 1; }

echo "Waiting for a blank disc in the drive..."
for i in $(seq 1 30); do
    # drutil prints nothing / "No Media Inserted" while the disc spins up;
    # only trust it once it reports the disc's writability.
    status=$(drutil status)
    if grep -q "Writability:" <<<"$status"; then
        break
    fi
    [ "$i" -eq 30 ] && { echo "No disc found after 60s." >&2; exit 1; }
    sleep 2
done
echo "$status"

if ! grep -qiE "Writability:.*(blank|appendable)" <<<"$status"; then
    echo "Disc does not look blank/writable — aborting." >&2
    exit 1
fi

echo "Burning $ISO (hdiutil verifies the burn and ejects when done)..."
hdiutil burn "$ISO"
echo "Done. Put the disc in the Xbox 360 (hard drive attached) to install the update."
