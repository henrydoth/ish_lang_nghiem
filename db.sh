#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/ln_lang_nghiem.bash"

export LN_FILE="$BASE_DIR/dai_bi.md"
ln "$@"
