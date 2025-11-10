#!/bin/bash
# test-wolftpm.sh
# Script to test wolfTPM image with software TPM simulator
#
# Usage: ./test-wolftpm.sh [build-directory]
# Example: ./test-wolftpm.sh ~/wolfwork/yocto/poky/build

set -e

# Configuration
BUILD_DIR="${1:-$HOME/wolfwork/yocto/poky/build}"
POKY_DIR="$HOME/wolfwork/yocto/poky"
TPM_STATE_DIR="/tmp/mytpm1"
IMAGE_NAME="wolftpm-image-minimal"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}wolfTPM Image Test Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Cleanup function
cleanup() {
    echo -e "${YELLOW}Cleaning up...${NC}"
    
    # Kill TPM simulator
    sudo killall swtpm 2>/dev/null || true
    
    # Remove TPM state directory
    sudo rm -rf "$TPM_STATE_DIR" 2>/dev/null || true
    
    echo -e "${GREEN}Cleanup complete!${NC}"
}

# Set trap to cleanup on exit
trap cleanup EXIT INT TERM

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}Error: Build directory not found: $BUILD_DIR${NC}"
    echo "Usage: $0 [build-directory]"
    exit 1
fi

# Check if poky directory exists
if [ ! -d "$POKY_DIR" ]; then
    echo -e "${RED}Error: Poky directory not found: $POKY_DIR${NC}"
    exit 1
fi

# Check if image has been built
IMAGE_DIR="$BUILD_DIR/tmp/deploy/images/qemux86-64"
if [ ! -d "$IMAGE_DIR" ]; then
    echo -e "${RED}Error: Image directory not found: $IMAGE_DIR${NC}"
    echo "Please build the image first with: bitbake $IMAGE_NAME"
    exit 1
fi

# Find the image file
IMAGE_FILE=$(find "$IMAGE_DIR" -name "${IMAGE_NAME}*.wic" -o -name "${IMAGE_NAME}*.ext4" | head -n1)
if [ -z "$IMAGE_FILE" ]; then
    echo -e "${RED}Error: No image file found for $IMAGE_NAME${NC}"
    echo "Please build the image first with: bitbake $IMAGE_NAME"
    exit 1
fi

# Check if swtpm is installed
if ! command -v swtpm &> /dev/null; then
    echo -e "${RED}Error: swtpm is not installed${NC}"
    echo "Install with: sudo apt-get install swtpm swtpm-tools"
    exit 1
fi

# Check if swtpm_setup is installed
if ! command -v swtpm_setup &> /dev/null; then
    echo -e "${RED}Error: swtpm_setup is not installed${NC}"
    echo "Install with: sudo apt-get install swtpm swtpm-tools"
    exit 1
fi

echo -e "${YELLOW}Step 1: Cleaning up any existing TPM state...${NC}"
sudo killall swtpm 2>/dev/null || true
sudo rm -rf "$TPM_STATE_DIR" 2>/dev/null || true

echo -e "${YELLOW}Step 2: Creating TPM state directory...${NC}"
sudo mkdir -p "$TPM_STATE_DIR"
sudo chown -R $(whoami):$(whoami) "$TPM_STATE_DIR"
chmod 755 "$TPM_STATE_DIR"

echo -e "${YELLOW}Step 3: Starting TPM simulator in background...${NC}"
sudo swtpm socket --tpmstate dir="$TPM_STATE_DIR" \
    --ctrl type=unixio,path="$TPM_STATE_DIR/swtpm-sock" \
    --log level=20 \
    --tpm2 \
    --daemon

# Give the simulator a moment to start
sleep 2

echo -e "${YELLOW}Step 4: Initializing TPM...${NC}"
sudo swtpm_setup --tpmstate "$TPM_STATE_DIR" \
    --createek \
    --create-ek-cert \
    --create-platform-cert \
    --lock-nvram \
    --tpm2

echo -e "${YELLOW}Step 5: Setting permissions for QEMU access...${NC}"
sudo chown -R $(whoami):$(whoami) "$TPM_STATE_DIR"
sudo chmod -R 755 "$TPM_STATE_DIR"
sudo chmod 777 "$TPM_STATE_DIR/swtpm-sock"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}TPM Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Starting QEMU with $IMAGE_NAME...${NC}"
echo ""
echo -e "${GREEN}To test wolfTPM inside QEMU, run:${NC}"
echo -e "  ${YELLOW}cd /usr/bin${NC}"
echo -e "  ${YELLOW}./wolftpm-wrap-test${NC}"
echo ""
echo -e "${GREEN}Press Ctrl-A then X to exit QEMU${NC}"
echo ""

# Source Yocto environment and run QEMU
cd "$POKY_DIR"
source oe-init-build-env "$BUILD_DIR" > /dev/null 2>&1

echo -e "${YELLOW}Found image: $(basename "$IMAGE_FILE")${NC}"
echo ""

runqemu qemux86-64 nographic "$IMAGE_FILE" \
    qemuparams="-chardev socket,id=chrtpm,path=$TPM_STATE_DIR/swtpm-sock \
    -tpmdev emulator,id=tpm0,chardev=chrtpm \
    -device tpm-tis,tpmdev=tpm0"

# Cleanup will be called automatically via trap

