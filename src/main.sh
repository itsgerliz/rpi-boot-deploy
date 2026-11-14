#!/bin/sh
set -eu

# Usage: ./main.sh <kernel_path> <initrd_path> <bootloader_directory>
# Note: Use absolute paths

# Require root permissions since we are modifying protected directories
if [ "$(id -u)" -ne 0 ]; then
	echo "Error: rpi-boot-deploy must be run as root" >&2
	exit 1
fi

# Check correct usage
if [ ! "$#" -eq 3 ]; then
	echo "Usage: $0 <kernel_path> <initrd_path> <bootloader_directory>" >&2
	echo "Note: Use absolute paths" >&2
	echo "Example: $0 /vmlinuz /initrd.img /boot/firmware" >&2
	exit 1
fi

NEW_KERNEL="$1"
NEW_INITRD="$2"
BOOTLOADER_DIRECTORY="${3%/}"
TARGET_KERNEL_PATH="$BOOTLOADER_DIRECTORY/kernel8.img"
TARGET_INITRD_PATH="$BOOTLOADER_DIRECTORY/initramfs8"

deploy() {
	cp "$NEW_KERNEL" "$TARGET_KERNEL_PATH"
	cp "$NEW_INITRD" "$TARGET_INITRD_PATH"
	sync
	echo "Success: rpi-boot-deploy completed successfully"
}

# Do new assets exist?
if [ ! -f "$NEW_KERNEL" ]  || [ ! -f "$NEW_INITRD" ] ; then
	echo "Error: '$NEW_KERNEL' or '$NEW_INITRD' does not exist, cannot deploy" >&2
	exit 1
fi

# Do targets exist?
if [ ! -f "$TARGET_KERNEL_PATH" ]  || [ ! -f "$TARGET_INITRD_PATH" ] ; then
	deploy
	exit 0
fi

# If they exist, are they equal?
NEW_KERNEL_HASH="$(sha256sum "$NEW_KERNEL" | cut -d ' ' -f 1)"
NEW_INITRD_HASH="$(sha256sum "$NEW_INITRD" | cut -d ' ' -f 1)"
TARGET_KERNEL_PATH_HASH="$(sha256sum "$TARGET_KERNEL_PATH" | cut -d ' ' -f 1)"
TARGET_INITRD_PATH_HASH="$(sha256sum "$TARGET_INITRD_PATH" | cut -d ' ' -f 1)"

if [ "$NEW_KERNEL_HASH" != "$TARGET_KERNEL_PATH_HASH" ] || [ "$NEW_INITRD_HASH" != "$TARGET_INITRD_PATH_HASH" ]; then
	deploy
	exit 0
else
	echo "Info: kernel and initrd are identical, skipping deploy"
	exit 0
fi
