#!/usr/bin/env bash
# ==========================================
# add_a_di_da.bash (iSH READY)
# Usage:
#   add               # Kinh A Di Đà: 1 → 17 (auto 60s) + rainbow theo dấu câu + wrap theo từ + 1 dòng trống mỗi câu
#   add 1 2           # Kinh A Di Đà: 1 → 2
#   add 5 17          # Kinh A Di Đà: 5 → 17
#
# Controls:
#   (no key) 60s = auto next
#   any key  = next immediately
#   q or ESC = quit
# ==========================================

# ---- Require bash (arrays + BASH_REMATCH + [[ ]] ) ----
if [[ -z "${BASH_VERSION:-}" ]]; then
  echo "❌ Script này cần bash. Trên iSH hãy chạy: apk add bash && bash"
  return 1 2>/dev/null || exit 1
fi

# ---- Paths: kinh_a_di_da.md nằm cùng thư mục script ----
_add_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
add_FILE="${add_FILE:-"$_add_DIR/kinh_a_di_da.md"}"

# ---- Default options for A Di Đà ----
add_TIMEOUT_DEFAULT="${add_TIMEOUT_DEFAULT:-60}"   # auto-next seconds
add_TITLE_DEFAULT="${add_TITLE_DEFAULT:-📿 TỤNG KINH / KINH A DI ĐÀ}"
add_PUNCT_RAINBOW_DEFAULT="${add_PUNCT_RAINBOW_DEFAULT:-1}"
add_SPACER_DEFAULT="${add_SPACER_DEFAULT:-1}"
add_WRAP_DEFAULT="${add_WRAP_DEFAULT:-1}"

# ---- TTY fallback ----
_add_TTY="/dev/tty"
[[ -r "$_add_TTY" && -w "$_add_TTY" ]] || _add_TTY=""

# ANSI
_reset=$'\033[0m'
_bold=$'\033[1m'
_red=$'\033[31m'
_green=$'\033[32m'
_white=$'\033[37m'
_yellow=$'\033[33m'
_gray=$'\033[90m'

# ---- Colors by line index (12-cycle) ----
_add_color_main() {
  local n="$1"
  local r=$(( (n - 1) % 12 ))
  if   (( r < 3 )); then echo "$_red"
  elif (( r < 6 )); then echo "$_green"
  elif (( r < 9 )); then echo "$_white"
  else                  echo "$_yellow"
  fi
}

_add_color_han() {
  local n="$1"
  local r=$(( (n - 1) % 12 ))
  if   (( r < 3 )); then echo "$_white"
  elif (( r < 6 )); then echo "$_yellow"
  elif (( r < 9 )); then echo "$_red"
  else                  echo "$_green"
  fi
}

# ---- Terminal cols ----
_add_cols() {
  local cols=""
  cols="$(tput cols 2>/dev/null || true)"
  [[ "$cols" =~ ^[0-9]+$ ]] || cols=80
  (( cols < 40 )) && cols=40
  echo "$cols"
}

# ---- Rainbow punct + wrap, keeps indent aligned ----
_add_print_punct_rainbow_wrap() {
  local s="$1"
  local cols="$2"
  local indent="$3"
  local bold="${4:-$_bold}"
  local reset="${5:-$_reset}"

  local colors=(
    $'\033[31m'  # đỏ
    $'\033[33m'  # vàng
    $'\033[32m'  # xanh lá
    $'\033[36m'  # cyan
    $'\033[35m'  # tím
  )

  s="$(printf "%s" "$s" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')"
  local tokens
  tokens="$(printf "%s" "$s" | sed -E 's/([.,!?;:…]+)/ \n\1\n /g')"

  local color_i=0
  local c="${colors[0]}"

  local col="$indent"
  local first_in_line=1

  _add__nl_indent() {
    echo
    printf "%*s" "$indent" ""
    col="$indent"
    first_in_line=1
  }

  local tok
  while IFS= read -r tok; do
    [[ -z "$tok" ]] && continue

    case "$tok" in
      *[!.,\?\!\;\:\…]*)
        # TEXT: split words
        local w
        while IFS= read -r w; do
          [[ -z "$w" ]] && continue
          local add_len=$(( ${#w} + (first_in_line ? 0 : 1) ))
          if (( col + add_len > cols )); then
            _add__nl_indent
          fi

          if (( first_in_line == 0 )); then
            printf " "
            col=$((col+1))
          fi

          printf "%s%s%s%s" "$bold" "$c" "$w" "$reset"
          col=$((col + ${#w}))
          first_in_line=0
        done < <(printf "%s" "$tok" | tr ' ' '\n')
        ;;
      *)
        # PUNCT
        local p="$tok"
        if (( col + ${#p} > cols )); then
          _add__nl_indent
        fi
        printf "%s%s%s%s" "$bold" "$c" "$p" "$reset"
        col=$((col + ${#p}))
        first_in_line=0

        color_i=$((color_i+1))
        c="${colors[$(( color_i % ${#colors[@]} ))]}"
        ;;
    esac
  done <<< "$tokens"
}

# ---- Read 1 key with timeout (auto-next) ----
_add_read_key() {
  local key=""
  local timeout="${add_TIMEOUT:-60}"

  if [[ -n "$_add_TTY" ]]; then
    stty -echo < "$_add_TTY" 2>/dev/null || true
    IFS= read -r -n 1 -t "$timeout" key < "$_add_TTY" 2>/dev/null || true
    stty echo < "$_add_TTY" 2>/dev/null || true
  else
    stty -echo 2>/dev/null || true
    IFS= read -r -n 1 -t "$timeout" key 2>/dev/null || true
    stty echo 2>/dev/null || true
  fi

  printf "%s" "$key"
}

# ---- End halo ----
_add_halo_end() {
  echo
  echo "🙏 Hết đoạn."

  local reset=$'\033[0m'
  local bold=$'\033[1m'
  local delay="${add_HALO_DELAY:-0.15}"

  local colors=(
    $'\033[31m'  # đỏ
    $'\033[33m'  # vàng
    $'\033[32m'  # xanh lá
    $'\033[36m'  # cyan
    $'\033[34m'  # xanh dương
    $'\033[35m'  # tím
  )

  local words=("Nam" "Mô" "A" "Di" "Đà" "Phật.")
  local i=0 c

  for w in "${words[@]}"; do
    c="${colors[$(( i % ${#colors[@]} ))]}"
    printf "%s%s%s%s " "$bold" "$c" "$w" "$reset"
    sleep "$delay" 2>/dev/null || true
    i=$((i+1))
  done
  echo
}

# ---- Core runner ----
_add_run() {
  local start="$1" end="$2"

  [[ -f "$add_FILE" ]] || { echo "❌ Không thấy file: $add_FILE"; return 1; }

  local total
  total="$(wc -l < "$add_FILE" 2>/dev/null)"
  [[ "$total" =~ ^[0-9]+$ ]] || total=0
  (( total > 0 && end > total )) && end="$total"
  (( total > 0 && start > total )) && { echo "❌ start vượt quá số dòng ($total)."; return 1; }

  clear
  echo "${add_TITLE:-📿 TỤNG KINH}"
  echo "File: $add_FILE"
  echo "Từ câu: $start → $end"
  echo "⏳ Tự động sau ${add_TIMEOUT}s | Phím bất kỳ: câu kế | q/ESC: thoát"
  echo "----------------------------------------"

  local i raw main han key c_main c_han stop=0
  local cols indent

  cols="$(_add_cols)"

  for (( i=start; i<=end; i++ )); do
    raw="$(sed -n "${i}p" "$add_FILE")"

    if [[ -z "${raw//[[:space:]]/}" ]]; then
      echo "${_gray}${i}.${_reset} ${_gray}(trống)${_reset}"
    else
      main="${raw%%#*}"
      han=""
      [[ "$raw" == *"#"* ]] && han="${raw#*#}"
      main="$(echo "$main" | sed -E 's/^[[:space:]]*[0-9]+[.)][[:space:]]*//')"

      c_main="$(_add_color_main "$i")"
      c_han="$(_add_color_han "$i")"

      indent=$(( ${#i} + 2 ))  # len("N. ")

      # MAIN
      printf "%s%d.%s " "$_gray" "$i" "$_reset"
      if [[ "${add_WRAP:-1}" == "1" && "${add_PUNCT_RAINBOW:-1}" == "1" ]]; then
        _add_print_punct_rainbow_wrap "$main" "$cols" "$indent" "$_bold" "$_reset"
        echo
      else
        printf "%s%s%s%s\n" "$_bold" "$c_main" "$main" "$_reset"
      fi

      # HAN (optional)
      if [[ -n "${han//[[:space:]]/}" ]]; then
        printf "%s#%s " "$_gray" "$_reset"
        if [[ "${add_WRAP:-1}" == "1" && "${add_PUNCT_RAINBOW:-1}" == "1" ]]; then
          _add_print_punct_rainbow_wrap "$han" "$cols" "$indent" "$_bold" "$_reset"
          echo
        else
          printf "%s%s%s%s\n" "$_bold" "$c_han" "$han" "$_reset"
        fi
      fi

      [[ "${add_SPACER:-1}" == "1" ]] && echo
    fi

    key="$(_add_read_key)"
    if [[ "$key" == $'\e' || "$key" == "q" || "$key" == "Q" ]]; then
      stop=1
      break
    fi
  done

  _add_halo_end
  return 0
}

# ==========================================
# Public: add (Kinh A Di Đà)
# ==========================================
add() {
  local start end

  if (( $# == 0 )); then
    start=1
    end=17
  else
    start="${1:-1}"
    end="${2:-17}"
  fi

  [[ "$start" =~ ^[0-9]+$ ]] || { echo "❌ start phải là số. Ví dụ: add 5 17"; return 1; }
  [[ "$end"   =~ ^[0-9]+$ ]] || { echo "❌ end phải là số. Ví dụ: add 5 17"; return 1; }
  (( end < start )) && { local t="$start"; start="$end"; end="$t"; }

  # apply defaults (can override by env vars before calling)
  add_TIMEOUT="${add_TIMEOUT:-$add_TIMEOUT_DEFAULT}"
  add_TITLE="${add_TITLE:-$add_TITLE_DEFAULT}"
  add_PUNCT_RAINBOW="${add_PUNCT_RAINBOW:-$add_PUNCT_RAINBOW_DEFAULT}"
  add_SPACER="${add_SPACER:-$add_SPACER_DEFAULT}"
  add_WRAP="${add_WRAP:-$add_WRAP_DEFAULT}"

  trap 'stty echo < /dev/tty 2>/dev/null || true' EXIT
  _add_run "$start" "$end"
}