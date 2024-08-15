#!/bin/bash

set -e

# Set up environment variables
REPO_DIR=$(pwd)
CONFIG_PATH="config"
OUTPUT_DIR="$REPO_DIR/builds"
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')

# Docker container and volume names
CONTAINER_NAME="zmk-build-container"
VOLUME_NAME="zmk-build-volume"

# Function to build firmware
build_firmware() {
    local SHIELD=$1
    local HALF=$2

    west build -s zmk/app -d "build_${HALF}" -b nice_nano_v2 -- \
        -DZMK_CONFIG="${CONFIG_PATH}" \
        -DSHIELD="${SHIELD}"

    mkdir -p /tmp/zmk-out
    cp "build_${HALF}/zephyr/zmk.uf2" "/tmp/zmk-out/${HALF}_half_${TIMESTAMP}.uf2"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Create Docker volume if it doesn't exist (this is idempotent)
docker volume create $VOLUME_NAME &> /dev/null

# Check if the container already exists, if not create it
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Creating new ZMK build container..."
    docker create --name $CONTAINER_NAME \
        -v $VOLUME_NAME:/workspace \
        -v "${REPO_DIR}/${CONFIG_PATH}:/workspace/${CONFIG_PATH}" \
        zmkfirmware/zmk-build-arm:stable \
        tail -f /dev/null
fi

# Check container status and act accordingly
CONTAINER_STATUS=$(docker inspect -f '{{.State.Status}}' $CONTAINER_NAME)

case $CONTAINER_STATUS in
    "running")
        echo "ZMK build container is already running."
        ;;
    "exited"|"created")
        echo "Starting ZMK build container..."
        docker start $CONTAINER_NAME
        ;;
    *)
        echo "Error: Unexpected container status: $CONTAINER_STATUS"
        exit 1
        ;;
esac

# Run the build process in the container
docker exec -it $CONTAINER_NAME /bin/bash -c "
    cd /workspace
    if [ ! -d '.west' ]; then
        west init -l ${CONFIG_PATH}
    fi
    west update
    west zephyr-export
    $(declare -f build_firmware)
    build_firmware splitkb_aurora_sweep_left left
    build_firmware splitkb_aurora_sweep_right right
"

# Copy the built firmware from the container to the host
echo "Copying firmware files to host..."
mkdir -p "$OUTPUT_DIR"
docker cp $CONTAINER_NAME:/tmp/zmk-out/. "$OUTPUT_DIR"

# Stop the container
echo "Stopping ZMK build container..."
docker stop $CONTAINER_NAME

echo "Build complete. Firmware files are in the 'builds' directory."
ls -l "$OUTPUT_DIR"
