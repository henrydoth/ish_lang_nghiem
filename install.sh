#!/usr/bin/env bash
set -euo pipefail

# Xác định root repo
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="$HOME/.local/bin"

echo "📦 Installing ish_lang_nghiem..."

# Tạo thư mục bin nếu chưa có
mkdir -p "$BIN_DIR"

# Đảm bảo script có quyền chạy
chmod +x "$ROOT/ln.sh"

# Dùng ln hệ thống (tránh trùng với function ln của bạn)
/bin/ln -sf "$ROOT/ln.sh" "$BIN_DIR/ln"
/bin/ln -sf "$ROOT/ln.sh" "$BIN_DIR/lnk"

echo "✅ Installed commands:"
echo "   ln"
echo "   lnk"

# Thêm PATH nếu chưa có
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo ""
  echo "🔧 Adding $BIN_DIR to PATH..."
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  echo "👉 PATH updated. Restart terminal or run: source ~/.bashrc"
fi


echo ""
echo "✨ Done."