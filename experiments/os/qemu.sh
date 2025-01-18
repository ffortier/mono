#!/usr/bin/env bash
copy=$(mktemp)

trap 'rm -f "$copy"' EXIT

cp "$1" "$copy"
chmod +w "$copy"

qemu-system-x86_64 -drive "format=raw,file=$copy" -nographic
