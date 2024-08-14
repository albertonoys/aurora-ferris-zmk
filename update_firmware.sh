#!/bin/bash

MOUNT_POINT="/media/$USER/NICENANO"
FIRMWARE_ZIP="$HOME/Downloads/firmware.zip"
LEFT_FIRMWARE="splitkb_aurora_sweep_left-nice_nano_v2-zmk.uf2"
RIGHT_FIRMWARE="splitkb_aurora_sweep_right-nice_nano_v2-zmk.uf2"

# Check if firmware .zip exists
if [ ! -f "$FIRMWARE_ZIP" ]; then
    gum style --foreground 196 "Error: Firmware .zip not found at $FIRMWARE_ZIP"
    exit 1
fi

# Function to wait for mount/unmount with timeout
wait_for_mount() {
    local action=$1
    local message=$2
    local timeout=30
    gum spin --spinner dot --title "$message" -- bash -c "
        start_time=\$(date +%s)
        while true; do
            current_time=\$(date +%s)
            if [ \$((current_time - start_time)) -ge $timeout ]; then
                echo 'timeout'
                exit 1
            fi
            if [ '$action' = 'mount' ] && [ -d '$MOUNT_POINT' ]; then
                break
            elif [ '$action' = 'unmount' ] && [ ! -d '$MOUNT_POINT' ]; then
                break
            fi
            sleep 1
        done
    "
    if [ $? -ne 0 ]; then
        gum style --foreground 196 "Timeout waiting for $action"
        exit 1
    fi
}

# Function to copy firmware
copy_firmware() {
    local firmware=$1
    local half=$2
    gum spin --spinner dot --title "Copying $half half firmware..." -- bash -c "
        unzip -p '$FIRMWARE_ZIP' '$firmware' > '$MOUNT_POINT/$firmware'
    "
    if [ $? -eq 0 ]; then
        gum style --foreground 212 "✓ Copied $firmware to $MOUNT_POINT"
    else
        gum style --foreground 196 "Error copying $firmware"
        exit 1
    fi
}

# Main process
gum style \
    --border normal \
    --margin "1" \
    --padding "1" \
    --border-foreground 212 \
    "Split keyboard firmware updater"

# Wait for initial mount
wait_for_mount "mount" "Waiting for left half to be mounted..."

# Copy left firmware
copy_firmware "$LEFT_FIRMWARE" "left"

# Wait for unmount
wait_for_mount "unmount" "Waiting for left half to be unmounted..."

# Wait for mount again
wait_for_mount "mount" "Waiting for right half to be mounted..."

# Copy right firmware
copy_firmware "$RIGHT_FIRMWARE" "right"

# Wait for final unmount
wait_for_mount "unmount" "Waiting for final unmount..."

# Confirm and remove firmware zip
if gum confirm "Do you want to remove the firmware .zip?"; then
    gum spin --spinner dot --title "Removing firmware zip..." -- rm "$FIRMWARE_ZIP"
    if [ $? -eq 0 ]; then
        gum style --foreground 212 "✓ Removed $FIRMWARE_ZIP"
    else
        gum style --foreground 196 "Error removing $FIRMWARE_ZIP"
    fi
else
    gum style --foreground 212 "Firmware .zip kept at $FIRMWARE_ZIP"
fi

gum style \
    --border normal \
    --margin "1" \
    --padding "1" \
    --border-foreground 212 \
    "Keeb flashed successfully! 🎉"