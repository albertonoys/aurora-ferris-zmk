#!/bin/bash

# MOUNT_POINT="/media/{YOUR_USER_HERE}/NICENANO"
FIRMWARE_ZIP="$HOME/Downloads/firmware.zip"
LEFT_FIRMWARE="splitkb_aurora_sweep_left-nice_nano_v2-zmk.uf2"
RIGHT_FIRMWARE="splitkb_aurora_sweep_right-nice_nano_v2-zmk.uf2"

# Function to wait for mount/unmount
wait_for_mount() {
    local action=$1
    while true; do
        if [ "$action" = "mount" ] && [ -d "$MOUNT_POINT" ]; then
            break
        elif [ "$action" = "unmount" ] && [ ! -d "$MOUNT_POINT" ]; then
            break
        fi
        sleep 1
    done
}

# Function to copy firmware
copy_firmware() {
    local firmware=$1
    unzip -p "$FIRMWARE_ZIP" "$firmware" > "$MOUNT_POINT/$firmware"
    echo "Copied $firmware to $MOUNT_POINT"
}

# Wait for initial mount
echo "Waiting for left half to be mounted..."
wait_for_mount "mount"

# Copy left firmware
echo "Copying left half firmware..."
copy_firmware "$LEFT_FIRMWARE"

# Wait for unmount
echo "Waiting for left half to be unmounted..."
wait_for_mount "unmount"

# Wait for mount again
echo "Waiting for right half to be mounted..."
wait_for_mount "mount"

# Copy right firmware
echo "Copying right half firmware..."
copy_firmware "$RIGHT_FIRMWARE"

# Wait for final unmount
echo "Waiting for final unmount..."
wait_for_mount "unmount"

# Remove firmware zip
rm "$FIRMWARE_ZIP"
echo "Removed $FIRMWARE_ZIP"

echo "Keeb flashed successfully!"
