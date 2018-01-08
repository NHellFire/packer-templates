#!/bin/sh
set -e
printf "Removing unneeded packages...\n"
apt-get autoremove --purge

printf "Cleaning APT package cache... "
apt-get clean
printf "done.\n"

printf "Cleaning /tmp... "
rm -rf /tmp/*
printf "done\n"

printf "Zeroing free space...\n"
dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY

SWAP_UUID="$(blkid -l -o value -s UUID -t TYPE=swap || true)"
if [ -n "$SWAP_UUID" ]; then
	printf "Zeroing swap...\n"
	SWAP_DEV="$(readlink -f "/dev/disk/by-uuid/$SWAP_UUID")"
	swapoff -a
	dd if=/dev/zero of="$SWAP_DEV" bs=1M || true
	mkswap -f -U "$SWAP_UUID" "$SWAP_DEV"
fi

SWAP_FILE="$(awk '$2 == "file" { print $1 }' /proc/swaps)"
if [ -n "$SWAP_FILE" ]; then
	printf "Zeroing swap file...\n"
	swapoff "$SWAP_FILE"
	SWAP_SIZE="$(stat --printf='%s' "$SWAP_FILE")"
	BS=1
	if [ "$((SWAP_SIZE%1048576))" = "0" ]; then
		BS=1M
		SWAP_SIZE="$((SWAP_SIZE/1048576))"
	elif [ "$((SWAP_SIZE%524288))" = "0" ]; then
		BS=512K
		SWAP_SIZE="$((SWAP_SIZE/524288))"
	elif [ "$((SWAP_SIZE%512))" = "0" ]; then
		BS=512
		SWAP_SIZE="$((SWAP_SIZE/512))"
	fi
	dd if=/dev/zero of="$SWAP_FILE" bs="$BS" count="$SWAP_SIZE" || true
	mkswap -f "$SWAP_FILE"
fi

exit 0
