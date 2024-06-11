#!/bin/sh
set -eux

KRNL_ROOT=$(pwd)

if test -d "$KRNL_ROOT/common/drivers"; then
	DRIVER_DIR="$KRNL_ROOT/common/drivers"
elif test -d "$KRNL_ROOT/drivers"; then
	DRIVER_DIR="$KRNL_ROOT/drivers"
else
	echo '[ERROR] "drivers/" directory is not found.'
	echo '[+] You should modify this script by yourself.'
	exit 127
fi

test -d "$KRNL_ROOT/KernelMemHack" || git clone https://github.com/aiichi/KernelMemHack

echo "[+] KERNEL_ROOT: $KRNL_ROOT"
echo "[+] Symlink KernelMemHack driver to $DRIVER_DIR"

cd "$DRIVER_DIR"
ln -sf "$(realpath --relative-to="$DRIVER_DIR" "$KRNL_ROOT/KernelMemHack/kernel")" "khack" && echo "[+] Symlink created."
cd "$KRNL_ROOT"

echo '[+] Add driver to Makefile & Kconfig'

DRIVER_MAKEFILE=$DRIVER_DIR/Makefile
DRIVER_KCONFIG=$DRIVER_DIR/Kconfig
grep -q "khack" "$DRIVER_MAKEFILE" || printf "obj-\$(CONFIG_KERNEL_HACK) += khack/\n" >> "$DRIVER_MAKEFILE"
grep -q "khack" "$DRIVER_KCONFIG" || sed -i "/endmenu/i\\source \"drivers/khack/Kconfig\"" "$DRIVER_KCONFIG"

echo '[+] Add KernelMemHack Done.'