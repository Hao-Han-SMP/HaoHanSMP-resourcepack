#!/bin/bash

DIR_NAME=$(basename "$PWD")
OUTPUT_DIR="out"
OUTPUT_NAME="${OUTPUT_DIR}/${DIR_NAME}.zip"

[ -d "$OUTPUT_DIR" ] || mkdir -p "$OUTPUT_DIR"
[ -f "$OUTPUT_NAME" ] && rm "$OUTPUT_NAME"

FILES_TO_ZIP=()
[ -d "assets" ] && FILES_TO_ZIP+=("assets")
[ -f "pack.mcmeta" ] && FILES_TO_ZIP+=("pack.mcmeta")
[ -f "pack.png" ] && FILES_TO_ZIP+=("pack.png")
[ -f "LICENSE" ] && FILES_TO_ZIP+=("LICENSE")
[ -f "README.md" ] && FILES_TO_ZIP+=("README.md")

if [ ${#FILES_TO_ZIP[@]} -eq 0 ]; then
    echo "Error: No resource pack files found to package!"
    exit 1
fi

echo "Packaging resource pack..."

if command -v zip >/dev/null 2>&1; then
    zip -rq "$OUTPUT_NAME" "${FILES_TO_ZIP[@]}"
    echo "Successfully packaged: $OUTPUT_NAME"
    exit 0
else
    echo "Error: 'zip' command not found on system!"
    echo "Please install 'zip' (e.g. 'sudo apt install zip' on Debian/Ubuntu) to proceed."
    exit 1
fi
