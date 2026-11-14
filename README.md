# rpi-boot-deploy
Raspberry Pi boot assets deployer script

# About
> [!NOTE]
> The script can be installed wherever you want, anyways, `/usr/local/sbin` is recommended

> [!TIP]
> An example apt hook is provided so this script executes automatically on each `apt upgrade`

This script essentially checks if the existing kernel and initrd in the Raspberry Pi  
bootloader directory are different from the provided ones, in such case it copies them

> [!WARNING]
> The script copies the kernel as `kernel8.img` and initrd as `initramfs8`, modify it if that is not your case
