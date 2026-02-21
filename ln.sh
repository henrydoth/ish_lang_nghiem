#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load functions
source "$BASE_DIR/ln_lang_nghiem.bash"

# Nếu user chạy: ./ln.sh 13 27 hoặc ./ln.sh 0*...
ln "$@"

