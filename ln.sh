#!/usr/bin/env bash

# Lấy thư mục của script
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
FILE="$BASE_DIR/lang_nghiem.md"

# Kiểm tra file tồn tại
if [[ ! -f "$FILE" ]]; then
  echo "Không tìm thấy lang_nghiem.md"
  exit 1
fi

# Nếu không truyền tham số → mặc định bắt đầu từ 1
start=${1:-1}

# Tính block 12 (13 → 24, 2 → 12, ...)
end=$(( ((start - 1) / 12 + 1) * 12 ))

# In nội dung từ start đến end
sed -n "${start},${end}p" "$FILE"