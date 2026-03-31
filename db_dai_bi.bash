#!/usr/bin/env bash
# ==========================================
# db_dai_bi.bash (iSH READY + AUTO 3s)
# Usage:
#   db 13             # 13 -> 24 (auto block 12)
#   db 13 27          # 13 -> 27
#   db 0*             # 1  -> 12
#   db 1*             # 13 -> 24
#   db 2*             # 25 -> 36
#   db 3*             # 37 -> 48
#   db 0* 1* 2*       # gộp nhiều block liền mạch
#   db 0*:2*          # range block: 0 tới 2
#   dbk "quang minh"  # tìm keyword -> chọn -> tụng tới hết block 12
# Keys while chanting:
#   (no key) 3s = auto next
#   any key  = next immediately
#   q or ESC = quit
# ==========================================

# ---- Require bash ----
if [[ -z "${BASH_VERSION:-}" ]]; then
  echo "❌ Script này cần bash. Trên iSH hãy chạy: apk add bash && bash"
  return 1 2>/dev/null || exit 1
fi

# ---- Portable path ----
_DB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_FILE="${DB_FILE:-"$_DB_DIR/dai_bi.md"}"

# ---- Optional title ----
DB_TITLE="${DB_TITLE:-🙏 TỤNG CHÚ ĐẠI BI}"

# ---- Optional: rainbow theo dấu câu (0/1) ----
DB_PUNCT_RAINBOW="${DB_PUNCT_RAINBOW:-0}"

# ---- Optional: spacer 1 dòng trống sau mỗi câu (0/1) ----
DB_SPACER="${DB_SPACER:-0}"

# ---- Optional: wrap theo từ (0/1) ----
DB_WRAP="${DB_WRAP:-0}"

# ---- TTY fallback ----
_DB_TTY="/dev/tty"
[[ -r "$_DB_TTY" && -w "$_DB_TTY" ]] || _DB_TTY=""

# ---- Auto-next seconds (default 3) ----
DB_TIMEOUT="${DB_TIMEOUT:-3}"

# ANSI
_reset=$'\033[0m'
_bold=$'\033[1m'
_red=$'\033[31m'
_green=$'\033[32m'
_white=$'\033[37m'
_yellow=$'\033[33m'
_gray=$'\033[90m'

# ---- Màu dịu, dễ tụng ----
# Phiên âm: 12 câu / vòng -> 3 trắng, 3 xanh, 3 vàng, 3 trắng
_db_color_main() {
  local n="$1"
  local r=$(( (n - 1) % 12 ))
  if   (( r < 3 )); then echo "$_white"
  elif (( r < 6 )); then echo "$_green"
  elif (( r < 9 )); then echo "$_yellow"
  else                  echo "$_white"
  fi
}

# Hán: 12 câu / vòng -> 3 vàng, 3 trắng, 3 vàng, 3 xanh
_db_color_han() {
  local n="$1"
  local r=$(( (n - 1) % 12 ))
  if   (( r < 3 )); then echo "$_yellow"
  elif (( r < 6 )); then echo "$_white"
  elif (( r < 9 )); then echo "$_yellow"
  else                  echo "$_green"
  fi
}

# ---- Terminal cols ----
_db_cols() {
  local cols=""
  cols="$(tput cols 2>/dev/null || true)"
  [[ "$cols" =~ ^[0-9]+$ ]] || cols=80
  (( cols < 40 )) && cols=40
  echo "$cols"
}

# ---- Wrap theo từ ----
_db_wrap_words() {
  local s="$1"
  local width="${2:-80}"
  local indent="${3:-0}"

  s="$(printf "%s" "$s" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')"
  local ind
  ind="$(printf '%*s' "$indent" "")"

  local out="" line="" w=""
  while IFS= read -r w; do
    [[ -z "$w" ]] && continue

    if [[ -z "$line" ]]; then
      line="$w"
    else
      if (( ${#line} + 1 + ${#w} <= width )); then
        line="$line $w"
      else
        out+="$line"$'\n'
        line="${ind}${w}"
      fi
    fi
  done < <(printf "%s" "$s" | tr ' ' '\n')

  out+="$line"
  printf "%s" "$out"
}

# ---- Rainbow theo dấu câu ----
_db_print_punct_rainbow() {
  local s="$1"
  local bold="${2:-$_bold}"
  local reset="${3:-$_reset}"

  local colors=(
    $'\033[37m'  # trắng
    $'\033[33m'  # vàng
    $'\033[32m'  # xanh lá
    $'\033[36m'  # cyan
    $'\033[35m'  # tím
  )

  local tokens
  tokens="$(printf "%s" "$s" | sed -E 's/([.,!?;:…]+)/\n\1\n/g')"

  local i=0
  local c="${colors[0]}"
  local buf="" t

  while IFS= read -r t; do
    [[ -z "$t" ]] && continue

    case "$t" in
      *[!.,\?\!\;\:\…]*)
        buf+="$t"
        ;;
      *)
        if [[ -n "$buf" ]]; then
          printf "%s%s%s%s" "$bold" "$c" "$buf" "$reset"
          buf=""
        fi
        printf "%s%s%s%s" "$bold" "$c" "$t" "$reset"
        i=$((i+1))
        c="${colors[$(( i % ${#colors[@]} ))]}"
        ;;
    esac
  done <<< "$tokens"

  if [[ -n "$buf" ]]; then
    printf "%s%s%s%s" "$bold" "$c" "$buf" "$reset"
  fi
}

# ---- Rainbow + wrap ----
_db_print_punct_rainbow_wrap() {
  local s="$1"
  local cols="$2"
  local indent="$3"
  local bold="${4:-$_bold}"
  local reset="${5:-$_reset}"

  local colors=(
    $'\033[37m'
    $'\033[33m'
    $'\033[32m'
    $'\033[36m'
    $'\033[35m'
  )

  s="$(printf "%s" "$s" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')"
  local tokens
  tokens="$(printf "%s" "$s" | sed -E 's/([.,!?;:…]+)/ \n\1\n /g')"

  local color_i=0
  local c="${colors[0]}"
  local col="$indent"
  local first_in_line=1

  _db__nl_indent() {
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
        local w
        while IFS= read -r w; do
          [[ -z "$w" ]] && continue
          local add_len=$(( ${#w} + (first_in_line ? 0 : 1) ))
          if (( col + add_len > cols )); then
            _db__nl_indent
          fi

          if (( first_in_line == 0 )); then
            printf " "
            col=$((col+1))
          fi

          printf "%s%s%s%s" "$bold" "$c" "$w" "$reset"
          col=$(( col + ${#w} ))
          first_in_line=0
        done < <(printf "%s" "$tok" | tr ' ' '\n')
        ;;
      *)
        local p="$tok"
        if (( col + ${#p} > cols )); then
          _db__nl_indent
        fi
        printf "%s%s%s%s" "$bold" "$c" "$p" "$reset"
        col=$(( col + ${#p} ))
        first_in_line=0

        color_i=$((color_i+1))
        c="${colors[$(( color_i % ${#colors[@]} ))]}"
        ;;
    esac
  done <<< "$tokens"
}

# ---- Read 1 key with timeout ----
_db_read_key() {
  local key=""
  local timeout="${DB_TIMEOUT}"

  if [[ -n "$_DB_TTY" ]]; then
    stty -echo < "$_DB_TTY" 2>/dev/null || true
    IFS= read -r -n 1 -t "$timeout" key < "$_DB_TTY" 2>/dev/null || true
    stty echo < "$_DB_TTY" 2>/dev/null || true
  else
    stty -echo 2>/dev/null || true
    IFS= read -r -n 1 -t "$timeout" key 2>/dev/null || true
    stty echo 2>/dev/null || true
  fi

  printf "%s" "$key"
}

# ---- Hào quang kết thúc ----
_db_halo_end() {
  echo
  echo "🙏 Hết đoạn."

  local reset=$'\033[0m'
  local bold=$'\033[1m'
  local delay="${DB_HALO_DELAY:-0.15}"

  local colors=(
    $'\033[31m'
    $'\033[33m'
    $'\033[32m'
    $'\033[36m'
    $'\033[34m'
    $'\033[35m'
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

# ---- Parse 1 line: bỏ số đầu dòng, tách main/han ----
_db_parse_line() {
  local raw="$1"

  local main="${raw%%#*}"
  local han=""
  [[ "$raw" == *"#"* ]] && han="${raw#*#}"

  main="$(printf "%s" "$main" | sed -E 's/^[[:space:]]*[0-9]+[.)]?[[:space:]]*//')"
  han="$(printf "%s" "$han"   | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"

  printf "%s\n%s\n" "$main" "$han"
}

# ==========================================
# db: tụng theo số
# ==========================================
db() {
  [[ -f "$DB_FILE" ]] || { echo "❌ Không thấy file: $DB_FILE"; return 1; }

  trap 'stty echo < /dev/tty 2>/dev/null || true' EXIT

  if [[ "${1:-}" =~ ^([0-9]+)\*:([0-9]+)\*$ ]]; then
    local b1="${BASH_REMATCH[1]}" b2="${BASH_REMATCH[2]}"
    (( b2 < b1 )) && { local t="$b1"; b1="$b2"; b2="$t"; }
    db "$(( b1*12 + 1 ))" "$(( (b2+1)*12 ))"
    return 0
  fi

  local ranges=()
  local block_labels=()
  local all_block_mode=true

  if (( $# == 0 )); then
    all_block_mode=false
  else
    for arg in "$@"; do
      [[ "$arg" =~ ^[0-9]+\*$ ]] || { all_block_mode=false; break; }
    done
  fi

  if [[ "$all_block_mode" == true ]]; then
    local blocks_sorted
    blocks_sorted="$(printf "%s\n" "$@" | sed 's/\*$//' | sort -n | uniq)"

    local first=1 cur_s=0 cur_e=0 cur_b1="" cur_b2="" b s e
    while IFS= read -r b; do
      [[ -n "$b" ]] || continue
      s=$(( b * 12 + 1 ))
      e=$(( s + 11 ))

      if (( first == 1 )); then
        cur_s=$s; cur_e=$e; cur_b1="$b"; cur_b2="$b"; first=0
      else
        if (( s <= cur_e + 1 )); then
          (( e > cur_e )) && cur_e=$e
          cur_b2="$b"
        else
          ranges+=( "${cur_s}:${cur_e}" )
          block_labels+=( "${cur_b1}*${cur_b2}" )
          cur_s=$s; cur_e=$e; cur_b1="$b"; cur_b2="$b"
        fi
      fi
    done <<< "$blocks_sorted"

    if (( first == 0 )); then
      ranges+=( "${cur_s}:${cur_e}" )
      block_labels+=( "${cur_b1}*${cur_b2}" )
    fi
  else
    local start="${1:-1}"
    local end="${2:-0}"
    local block_note=""

    if [[ "$start" =~ ^([0-9]+)\*$ ]]; then
      local block="${BASH_REMATCH[1]}"
      start=$(( block * 12 + 1 ))
      end=$(( start + 11 ))
      block_note="${block}*12"
    fi

    [[ "$start" =~ ^[0-9]+$ ]] || { echo "❌ start phải là số hoặc dạng K*"; return 1; }
    [[ "$end"   =~ ^[0-9]+$ ]] || { echo "❌ end phải là số"; return 1; }

    if (( end == 0 )); then
      end=$(( ((start - 1) / 12 + 1) * 12 ))
      block_note="$(( (start - 1) / 12 ))*12"
    fi

    (( end < start )) && { local t="$start"; start="$end"; end="$t"; }

    ranges+=( "${start}:${end}" )
    block_labels+=( "$block_note" )
  fi

  local total
  total="$(wc -l < "$DB_FILE" 2>/dev/null)"
  [[ "$total" =~ ^[0-9]+$ ]] || total=0

  local fixed_ranges=() fixed_labels=() idx=0 r rs re
  for r in "${ranges[@]}"; do
    rs="${r%%:*}"
    re="${r##*:}"
    (( total > 0 && re > total )) && re="$total"
    (( total > 0 && rs > total )) && continue
    fixed_ranges+=( "${rs}:${re}" )
    fixed_labels+=( "${block_labels[$idx]}" )
    idx=$((idx+1))
  done
  ranges=( "${fixed_ranges[@]}" )
  block_labels=( "${fixed_labels[@]}" )
  (( ${#ranges[@]} == 0 )) && { echo "❌ Không có đoạn hợp lệ để tụng."; return 1; }

  clear
  echo "$DB_TITLE"
  echo "File: $DB_FILE"

  if (( ${#ranges[@]} == 1 )); then
    local rs="${ranges[0]%%:*}"
    local re="${ranges[0]##*:}"
    echo "Từ câu: $rs → $re"
    [[ -n "${block_labels[0]}" ]] && echo "Block: ${block_labels[0]}"
  else
    echo "Đoạn tụng:"
    local k
    for (( k=0; k<${#ranges[@]}; k++ )); do
      echo "  - ${ranges[$k]%%:*} → ${ranges[$k]##*:}"
    done
  fi

  echo "⏳ Tự động sau ${DB_TIMEOUT}s | Phím bất kỳ: câu kế | q/ESC: thoát"
  echo "----------------------------------------"

  local i raw parsed main han key c_main c_han stop=0

  for r in "${ranges[@]}"; do
    local start="${r%%:*}"
    local end="${r##*:}"

    for (( i=start; i<=end; i++ )); do
      raw="$(sed -n "${i}p" "$DB_FILE")"

      if [[ -z "${raw//[[:space:]]/}" ]]; then
        echo "${_gray}$(printf '%02d' "$i").${_reset} ${_gray}(trống)${_reset}"
      else
        parsed="$(_db_parse_line "$raw")"
        main="$(printf "%s" "$parsed" | sed -n '1p')"
        han="$(printf "%s" "$parsed"  | sed -n '2p')"

        c_main="$(_db_color_main "$i")"
        c_han="$(_db_color_han "$i")"

        local cols indent width
        cols="$(_db_cols)"
        indent=4                 # "NN. " = 4 ký tự
        width=$cols
        (( width < 40 )) && width=40

        # ---- PRINT MAIN ----
        printf "%s%02d.%s " "$_gray" "$i" "$_reset"

        if [[ "${DB_WRAP:-0}" == "1" && "${DB_PUNCT_RAINBOW:-0}" == "1" ]]; then
          _db_print_punct_rainbow_wrap "$main" "$width" "$indent" "$_bold" "$_reset"
          echo
        elif [[ "${DB_WRAP:-0}" == "1" ]]; then
          local wrapped line
          wrapped="$(_db_wrap_words "$main" $(( width - indent )) "$indent")"
          local first_line=1
          while IFS= read -r line; do
            if (( first_line == 1 )); then
              printf "%s%s%s%s\n" "$_bold" "$c_main" "$line" "$_reset"
              first_line=0
            else
              printf "%*s%s%s%s%s\n" "$indent" "" "$_bold" "$c_main" "$line" "$_reset"
            fi
          done <<< "$wrapped"
        else
          if [[ "${DB_PUNCT_RAINBOW:-0}" == "1" ]]; then
            _db_print_punct_rainbow "$main" "$_bold" "$_reset"
          else
            printf "%s%s%s%s" "$_bold" "$c_main" "$main" "$_reset"
          fi
          if [[ -n "${han//[[:space:]]/}" ]]; then
            printf " %s#%s " "$_gray" "$_reset"
            if [[ "${DB_PUNCT_RAINBOW:-0}" == "1" ]]; then
              _db_print_punct_rainbow "$han" "$_bold" "$_reset"
            else
              printf "%s%s%s%s" "$_bold" "$c_han" "$han" "$_reset"
            fi
          fi
          echo
        fi

        # ---- PRINT HAN riêng dòng nếu đang wrap ----
        if [[ "${DB_WRAP:-0}" == "1" && -n "${han//[[:space:]]/}" ]]; then
          printf "%*s%s#%s " "$indent" "" "$_gray" "$_reset"
          if [[ "${DB_PUNCT_RAINBOW:-0}" == "1" ]]; then
            _db_print_punct_rainbow_wrap "$han" "$width" "$indent" "$_bold" "$_reset"
            echo
          else
            local wrapped_h line_h
            wrapped_h="$(_db_wrap_words "$han" $(( width - indent - 2 )) "$indent")"
            local first_h=1
            while IFS= read -r line_h; do
              if (( first_h == 1 )); then
                printf "%s%s%s%s\n" "$_bold" "$c_han" "$line_h" "$_reset"
                first_h=0
              else
                printf "%*s%s%s%s%s\n" "$(( indent + 2 ))" "" "$_bold" "$c_han" "$line_h" "$_reset"
              fi
            done <<< "$wrapped_h"
          fi
        fi

        if [[ "${DB_SPACER:-0}" == "1" ]]; then
          echo
        fi
      fi

      key="$(_db_read_key)"
      if [[ "$key" == $'\e' || "$key" == "q" || "$key" == "Q" ]]; then
        stop=1
        break
      fi
    done

    (( stop == 1 )) && break
  done

  _db_halo_end
}

# ==========================================
# dbk: tìm keyword -> chọn -> tụng tới hết block 12
# ==========================================
dbk() {
  local kw="$*"
  [[ -n "${kw//[[:space:]]/}" ]] || { echo '❌ Nhập từ khoá. Ví dụ: dbk "quang minh"'; return 1; }
  [[ -f "$DB_FILE" ]] || { echo "❌ Không thấy file: $DB_FILE"; return 1; }

  local matches
  matches="$(grep -in -- "$kw" "$DB_FILE" 2>/dev/null | head -n 200)"
  [[ -n "$matches" ]] || { echo "❌ Không tìm thấy: $kw"; return 1; }

  echo "🔎 Tìm thấy các câu có: \"$kw\""
  echo "----------------------------------------"
  echo "$matches" | while IFS=: read -r n line; do
    local before="${line%%#*}"
    before="$(printf "%s" "$before" | sed -E 's/^[[:space:]]*[0-9]+[.)]?[[:space:]]*//')"
    printf "%s%02d%s  %s\n" "$_gray" "$n" "$_reset" "$before"
  done

  echo "----------------------------------------"
  echo "Nhập số câu muốn tụng. Enter = câu đầu tiên. q = thoát"
  printf "> "

  local pick
  if [[ -n "$_DB_TTY" ]]; then
    IFS= read -r pick < "$_DB_TTY" 2>/dev/null || pick=""
  else
    IFS= read -r pick 2>/dev/null || pick=""
  fi

  [[ "$pick" == "q" || "$pick" == "Q" ]] && return 0

  local start
  if [[ -z "${pick//[[:space:]]/}" ]]; then
    start="$(echo "$matches" | head -n 1 | cut -d: -f1)"
  else  
    [[ "$pick" =~ ^[0-9]+$ ]] || { echo "❌ Phải nhập số."; return 1; }
    start="$pick"
  fi

  db "$start" $(( ((start - 1) / 12 + 1) * 12 ))
}
