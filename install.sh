#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

echo "📦 Installing ish_lang_nghiem..."

mkdir -p "$BIN_DIR"
chmod +x "$ROOT/ln.sh"

# Wrapper ln: $0 sẽ là ln (OK)
cat > "$BIN_DIR/ln" <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec "$ROOT/ln.sh" "\$@"
EOF

# Wrapper lnk: ép \$0 thành "lnk" để ln.sh nhận đúng mode
cat > "$BIN_DIR/lnk" <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec bash -c 'exec "$ROOT/ln.sh" "\$@"' lnk "\$@"
EOF

chmod +x "$BIN_DIR/ln" "$BIN_DIR/lnk"

echo "✅ Installed: ln, lnk"

# Add PATH if missing
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  echo "👉 PATH updated. Restart terminal or run: source ~/.bashrc"
fi

echo "✨ Done."