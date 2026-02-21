#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load functions
source "$BASE_DIR/ln_lang_nghiem.bash"

# Tên lệnh được gọi (ln hay lnk nếu tạo symlink)
CMD="$(basename "$0")"

# Nếu được gọi bằng tên lnk -> chạy lnk
if [[ "$CMD" == "lnk" ]]; then
  lnk "$@"
  exit 0
fi

# Mặc định -> ln
ln "$@"
