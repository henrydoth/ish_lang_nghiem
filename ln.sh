#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load functions
source "$BASE_DIR/ln_lang_nghiem.bash"

# Nếu không truyền tham số thì vẫn chạy được
ARGS=("$@")

# Tên lệnh được gọi (ln hay lnk nếu tạo symlink)
CMD="$(basename "$0")"

if [[ "$CMD" == "lnk" ]]; then
  lnk "${ARGS[@]}"
else
  ln "${ARGS[@]}"
fi
