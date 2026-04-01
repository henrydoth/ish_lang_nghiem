#!/usr/bin/env bash
set -euo pipefail

# ==== Require bash ====
if [[ -z "${BASH_VERSION:-}" ]]; then
  echo "❌ Script này cần bash."
  exit 1
fi

# ==== Config ====
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE="$BASE_DIR/thap-chu.md"
TC_TIMEOUT="${TC_TIMEOUT:-2}"

# ==== TTY fallback ====
_TC_TTY="/dev/tty"
[[ -r "$_TC_TTY" && -w "$_TC_TTY" ]] || _TC_TTY=""

# ==== ANSI ====
_reset=$'\033[0m'
_bold=$'\033[1m'
_red=$'\033[31m'
_green=$'\033[32m'
_white=$'\033[37m'
_yellow=$'\033[33m'
_gray=$'\033[90m'
_pink=$'\033[95m'

# Phiên âm: 12 câu / vòng -> 3 đỏ, 3 xanh, 3 trắng, 3 vàng
_tc_color_main() {
  local n="$1"
  local r=$(( (n - 1) % 12 ))
  if   (( r < 3 )); then echo "$_red"
  elif (( r < 6 )); then echo "$_green"
  elif (( r < 9 )); then echo "$_white"
  else                  echo "$_yellow"
  fi
}

# Hán: 12 câu / vòng -> 3 trắng, 3 vàng, 3 đỏ, 3 xanh
_tc_color_han() {
  local n="$1"
  local r=$(( (n - 1) % 12 ))
  if   (( r < 3 )); then echo "$_white"
  elif (( r < 6 )); then echo "$_yellow"
  elif (( r < 9 )); then echo "$_red"
  else                  echo "$_green"
  fi
}

# ==== Read 1 key with timeout ====
_tc_read_key() {
  local key=""
  local timeout="${TC_TIMEOUT}"

  if [[ -n "$_TC_TTY" ]]; then
    stty -echo < "$_TC_TTY" 2>/dev/null || true
    IFS= read -r -n 1 -t "$timeout" key < "$_TC_TTY" 2>/dev/null || true
    stty echo < "$_TC_TTY" 2>/dev/null || true
  else
    stty -echo 2>/dev/null || true
    IFS= read -r -n 1 -t "$timeout" key 2>/dev/null || true
    stty echo 2>/dev/null || true
  fi

  printf "%s" "$key"
}

_tc_halo_end() {
  echo
  echo -e "${_green}🙏 Nam Mô A Di Đà Phật 🙏${_reset}"
}

if [[ ! -f "$FILE" ]]; then
  echo "❌ Không tìm thấy thap-chu.md"
  exit 1
fi

# ===== LIST =====
if [[ $# -eq 0 ]]; then
  echo -e "${_pink}${_bold}📿 THẬP CHÚ${_reset}"
  grep -E '^[0-9]{2}\)' "$FILE"
  exit 0
fi

start="$1"
end="${2:-$1}"

if ! [[ "$start" =~ ^[0-9]+$ ]]; then
  echo "❌ start phải là số, ví dụ: tc 5"
  exit 1
fi

if ! [[ "$end" =~ ^[0-9]+$ ]]; then
  echo "❌ end phải là số, ví dụ: tc 3 5"
  exit 1
fi

total=$(grep -cE '^[0-9]{2}\)' "$FILE")

if (( start < 1 || start > total )); then
  echo "❌ Chú bắt đầu phải từ 1 đến $total"
  exit 1
fi

if (( end < start || end > total )); then
  echo "❌ Chú kết thúc phải từ $start đến $total"
  exit 1
fi

s_line=$(grep -nE '^[0-9]{2}\)' "$FILE" | sed -n "${start}p" | cut -d: -f1)

if (( end < total )); then
  next_line=$(grep -nE '^[0-9]{2}\)' "$FILE" | sed -n "$((end + 1))p" | cut -d: -f1)
  e_line=$((next_line - 1))
else
  e_line=$(wc -l < "$FILE")
fi

echo
echo -e "${_pink}${_bold}📿 TỤNG THẬP CHÚ${_reset}"
echo -e "${_yellow}${_bold}Chú: $start → $end${_reset}"
echo "⏳ Tự động sau ${TC_TIMEOUT}s | Phím bất kỳ: câu kế | q/ESC: thoát"
echo "----------------------------------------"

stop=0

sed -n "${s_line},${e_line}p" "$FILE" | while IFS= read -r line; do

  # ----- Header từng chú: 03) ... # 漢字 -----
  if [[ "$line" =~ ^([0-9]{2})\) ]]; then
    head_num="${BASH_REMATCH[1]}"
    main="${line%%#*}"
    han=""
    [[ "$line" == *"#"* ]] && han="${line#*#}"

    main="$(printf '%s' "$main" | sed 's/[[:space:]]*$//')"
    han="$(printf '%s' "$han"  | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

    c_han="$(_tc_color_han "$((10#$head_num))")"

    printf "%s%s%s" "$_pink" "$_bold" "$main"

    if [[ -n "$han" ]]; then
      printf " %s#%s %s%s%s%s" \
        "$_gray" "$_reset" \
        "$_bold" "$c_han" "$han" "$_reset"
    fi

    printf "%s\n" "$_reset"

  # ----- Dòng nội dung: 01. ... # 漢字 -----
  elif [[ "$line" =~ ^[0-9]{2}\. ]]; then
    num="${line%%.*}"
    rest="${line#*. }"
    main="${rest%%#*}"
    han=""
    [[ "$rest" == *"#"* ]] && han="${rest#*#}"

    main="$(printf '%s' "$main" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    han="$(printf '%s' "$han"  | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

    n=$((10#$num))
    c_main="$(_tc_color_main "$n")"
    c_han="$(_tc_color_han "$n")"

    printf "%s%s.%s %s%s%s%s" \
      "$_gray" "$num" "$_reset" \
      "$_bold" "$c_main" "$main" "$_reset"

    if [[ -n "$han" ]]; then
      printf " %s#%s %s%s%s%s" \
        "$_gray" "$_reset" \
        "$_bold" "$c_han" "$han" "$_reset"
    fi

    printf "\n"

  else
    echo "$line"
  fi

  key="$(_tc_read_key)"
  if [[ "$key" == $'\e' || "$key" == "q" || "$key" == "Q" ]]; then
    stop=1
    break
  fi
done

if (( stop == 1 )); then
  echo
  exit 0
fi

_tc_halo_end