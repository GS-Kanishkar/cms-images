#!/bin/bash

SRC_DIR="/root/my-repo/cms-images"
DST_DIR="/root/my-repo/images"

mkdir -p "$DST_DIR"

# Loop through each subfolder
for folder in "$SRC_DIR"/*/ ; do
  cd "$folder" || continue

  echo "Processing folder: $folder"

  # Find all split files by unique prefix
  for prefix in $(ls *_part_* 2>/dev/null | sed 's/_part_.*//' | sort -u); do
    echo "➡️ Reconstructing: $prefix"

    # Concatenate split parts back to .tar.gz
    cat "${prefix}_part_"* > "${prefix}.tar.gz"

    # Un-gzip to get original .tar
    gunzip -f "${prefix}.tar.gz"

    # Move the .tar to destination
    mv "${prefix}.tar" "$DST_DIR/"

    echo "✅ Moved ${prefix}.tar to $DST_DIR"
  done
done

echo "All tar files are now in $DST_DIR"

# Trigger the push script
if [ -f "$PUSH_SCRIPT" ]; then
  echo "🚀 Running push script: $PUSH_SCRIPT"
  bash "$PUSH_SCRIPT"
else
  echo "⚠️ Push script not found at $PUSH_SCRIPT"
fi
