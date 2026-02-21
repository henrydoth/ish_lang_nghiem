#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$HOME/.local/bin"

echo "🧹 Uninstalling ish_lang_nghiem commands..."

# Xoá symlink/command nếu tồn tại
rm -f "$BIN_DIR/ln" "$BIN_DIR/lnk"

echo "✅ Removed:"
echo "   $BIN_DIR/ln"
echo "   $BIN_DIR/lnk"

echo ""
echo "ℹ️  Nếu bạn đã thêm PATH vào ~/.bashrc trước đó, dòng này có thể vẫn còn:"
echo 'export PATH="$HOME/.local/bin:$PATH"'
echo "Bạn có thể mở ~/.bashrc và xoá dòng đó nếu muốn."
echo ""
echo "✨ Done."

