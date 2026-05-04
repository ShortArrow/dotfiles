#!/usr/bin/env bash
# dotfiles common library (bash).
#
# Sourced by every <tool>/setup.sh to share symlink / log / parser logic.
# Targets bash 4+. macOS readlink -f is unavailable; we use a portable form.
#
# Public surface:
#   dotfile_info / warn / error
#   expand_dotfile_vars  <path>       # echoes expanded path
#   new_dotfile_symlink  <src> <dst>  # echoes 'created' | 'replaced' | 'noop'
#   read_dotfile_registry  <path> <tool> <linux|macos>   # echoes "<src_kind>\t<src or dir>\t<include csv>\t<dst>" lines
#   set_dotfile_links  <tool> [<dotfiles_root>]
#   append_unique_line   <file> <line>

set -o errexit
set -o pipefail
set -o nounset

DOTFILE_LIB_VERSION=1

dotfile_info()  { printf '\033[36m==>\033[0m %s\n' "$*"; }
dotfile_ok()    { printf '\033[32m   \033[0m %s\n' "$*"; }
dotfile_warn()  { printf '\033[33m   \033[0m %s\n' "$*" >&2; }
dotfile_error() { printf '\033[31m!!!\033[0m %s\n' "$*" >&2; }

dotfile_os() {
  case "$(uname -s)" in
    Linux*)   printf 'linux' ;;
    Darwin*)  printf 'macos' ;;
    MINGW*|MSYS*|CYGWIN*) printf 'windows' ;;
    *)        printf 'unknown' ;;
  esac
}

# Resolve a script path to its directory portably (works on macOS too).
dotfile_script_dir() {
  local target="$1"
  ( cd -P "$(dirname "$target")" && pwd )
}

expand_dotfile_vars() {
  local path="$1"
  local home_dir="${HOME:-}"
  local xdg="${XDG_CONFIG_HOME:-}"
  if [[ -z "$xdg" ]]; then xdg="$home_dir/.config"; fi

  path="${path//\$HOME/$home_dir}"
  path="${path//\$XDG_CONFIG_HOME/$xdg}"
  if [[ -n "${USERPROFILE:-}" ]];   then path="${path//\$USERPROFILE/$USERPROFILE}"; fi
  if [[ -n "${APPDATA:-}" ]];       then path="${path//\$APPDATA/$APPDATA}"; fi
  if [[ -n "${LOCALAPPDATA:-}" ]];  then path="${path//\$LOCALAPPDATA/$LOCALAPPDATA}"; fi
  if [[ "$path" == "~" ]]; then
    path="$home_dir"
  elif [[ "$path" == "~/"* ]]; then
    path="$home_dir/${path:2}"
  fi

  printf '%s' "$path"
}

new_dotfile_symlink() {
  local src="$1" dst="$2"

  if [[ ! -e "$src" && ! -L "$src" ]]; then
    dotfile_error "source does not exist: $src"
    return 1
  fi

  local parent
  parent="$(dirname "$dst")"
  [[ -d "$parent" ]] || mkdir -p "$parent"

  if [[ -L "$dst" ]]; then
    local existing
    existing="$(readlink "$dst")"
    # Compare absolute paths if possible
    local existing_abs src_abs
    if existing_abs=$(cd "$(dirname "$existing")" 2>/dev/null && printf '%s/%s' "$(pwd)" "$(basename "$existing")"); then :; else existing_abs="$existing"; fi
    if src_abs=$(cd "$(dirname "$src")" 2>/dev/null && printf '%s/%s' "$(pwd)" "$(basename "$src")"); then :; else src_abs="$src"; fi
    if [[ "$existing_abs" == "$src_abs" || "$existing" == "$src" ]]; then
      dotfile_ok "noop  $dst"
      printf 'noop'
      return 0
    fi
    rm -f "$dst"
    ln -s "$src" "$dst"
    dotfile_ok "replaced $dst -> $src"
    printf 'replaced'
    return 0
  fi

  if [[ -e "$dst" ]]; then
    local bak="$dst.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$bak"
    dotfile_warn "backup $dst -> $bak"
    ln -s "$src" "$dst"
    dotfile_ok "replaced $dst -> $src"
    printf 'replaced'
    return 0
  fi

  ln -s "$src" "$dst"
  dotfile_ok "created $dst -> $src"
  printf 'created'
}

# Stream parser. Emits TSV lines for the requested tool/os:
#   <src_kind>\t<path-or-dir>\t<include-csv>\t<dst>
# src_kind = 'path' or 'expand'.
read_dotfile_registry() {
  local toml="$1" tool="$2" os_key="$3"
  awk -v want_tool="$tool" -v want_os="$os_key" '
    function trim(s) { sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
    function strip_comment(s,   i, c, in_str) {
      in_str = 0
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\"") in_str = !in_str
        if (c == "#" && !in_str) return substr(s, 1, i-1)
      }
      return s
    }

    function flush() {
      if (in_link == 0) return
      if (link_tool != want_tool) return
      if (link_dst == "") return
      inc = link_include; if (inc == "") inc = "-"
      if (link_kind == "path") {
        printf "path\t%s\t%s\t%s\n", link_src, inc, link_dst
      } else {
        printf "expand\t%s\t%s\t%s\n", link_dir, inc, link_dst
      }
    }

    BEGIN { tool=""; in_link=0; link_tool="" }
    {
      line = strip_comment($0)
      line = trim(line)
      if (line == "") next

      # [[tools.<name>.links]]
      if (match(line, /^\[\[tools\.[^.]+\.links\]\]$/)) {
        flush()
        tool = line; sub(/^\[\[tools\./, "", tool); sub(/\.links\]\]$/, "", tool)
        link_tool = tool
        in_link = 1
        link_src = ""; link_kind = "path"; link_dir = ""; link_include = ""; link_dst = ""
        next
      }
      # [tools.<name>]
      if (match(line, /^\[tools\.[^.]+\]$/)) {
        flush()
        tool = line; sub(/^\[tools\./, "", tool); sub(/\]$/, "", tool)
        in_link = 0
        next
      }
      # [tools.<name>.something_else] or [[tools.<name>.post_apply]]
      if (match(line, /^\[\[?tools\./)) {
        flush()
        in_link = 0
        next
      }

      if (in_link == 0) next
      if (link_tool != want_tool) next

      # src = "..."
      if (match(line, /^src[[:space:]]*=[[:space:]]*"[^"]*"$/)) {
        s = line; sub(/^src[[:space:]]*=[[:space:]]*"/, "", s); sub(/"$/, "", s)
        link_src = s; link_kind = "path"
        next
      }
      # src = { dir = "...", include = [ "a", "b" ] }
      if (match(line, /^src[[:space:]]*=[[:space:]]*\{.*\}$/)) {
        link_kind = "expand"
        inner = line; sub(/^src[[:space:]]*=[[:space:]]*\{/, "", inner); sub(/\}$/, "", inner)
        if (match(inner, /dir[[:space:]]*=[[:space:]]*"[^"]+"/)) {
          piece = substr(inner, RSTART, RLENGTH)
          sub(/^dir[[:space:]]*=[[:space:]]*"/, "", piece); sub(/"$/, "", piece)
          link_dir = piece
        }
        if (match(inner, /include[[:space:]]*=[[:space:]]*\[[^]]*\]/)) {
          arr = substr(inner, RSTART, RLENGTH)
          sub(/^include[[:space:]]*=[[:space:]]*\[/, "", arr); sub(/\]$/, "", arr)
          gsub(/[[:space:]]/, "", arr); gsub(/"/, "", arr)
          link_include = arr
        }
        next
      }
      # dst.<os> = "..."
      if (match(line, /^dst\.[a-z]+[[:space:]]*=[[:space:]]*"[^"]*"$/)) {
        os = line; sub(/^dst\./, "", os); sub(/[[:space:]].*$/, "", os)
        v = line; sub(/^dst\.[a-z]+[[:space:]]*=[[:space:]]*"/, "", v); sub(/"$/, "", v)
        if (os == want_os) link_dst = v
        next
      }
    }

    END { flush() }
  ' "$toml"
}

# True iff platforms array is empty or contains <os>
dotfile_tool_supports_os() {
  local toml="$1" tool="$2" os_key="$3"
  local platforms
  platforms="$(awk -v want_tool="$tool" '
    BEGIN { in_tool = 0 }
    /^\[tools\.[^.]+\]$/ {
      t = $0; sub(/^\[tools\./, "", t); sub(/\]$/, "", t)
      in_tool = (t == want_tool)
      next
    }
    /^\[/ { in_tool = 0; next }
    in_tool && /^platforms[[:space:]]*=/ {
      sub(/^platforms[[:space:]]*=[[:space:]]*\[/, "")
      sub(/\].*$/, "")
      gsub(/[[:space:]"]/, "")
      print
      exit
    }
  ' "$toml")"
  if [[ -z "$platforms" ]]; then return 0; fi
  IFS=',' read -ra arr <<< "$platforms"
  for p in "${arr[@]}"; do
    [[ "$p" == "$os_key" ]] && return 0
  done
  return 1
}

set_dotfile_links() {
  local tool="$1"
  local dotfiles_root="${2:-}"
  if [[ -z "$dotfiles_root" ]]; then
    dotfiles_root="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  fi
  local toml="$dotfiles_root/dotfm.toml"
  local os_key
  os_key="$(dotfile_os)"
  if [[ "$os_key" == "windows" ]]; then os_key="windows"; fi  # MSYS branch

  if ! dotfile_tool_supports_os "$toml" "$tool" "$os_key"; then
    dotfile_warn "tool '$tool' is not enabled for $os_key; skipping."
    return 0
  fi

  dotfile_info "set $tool ($os_key)"

  local count=0
  while IFS=$'\t' read -r kind a b dst_template; do
    [[ -z "$kind" ]] && continue
    [[ "$b" == "-" ]] && b=""
    local dst
    dst="$(expand_dotfile_vars "$dst_template")"
    if [[ "$kind" == "path" ]]; then
      local src="$dotfiles_root/$a"
      new_dotfile_symlink "$src" "$dst" >/dev/null
      count=$((count+1))
    elif [[ "$kind" == "expand" ]]; then
      local src_dir="$dotfiles_root/$a"
      IFS=',' read -ra includes <<< "$b"
      for name in "${includes[@]}"; do
        [[ -z "$name" ]] && continue
        new_dotfile_symlink "$src_dir/$name" "$dst/$name" >/dev/null
        count=$((count+1))
      done
    fi
  done < <(read_dotfile_registry "$toml" "$tool" "$os_key")

  if [[ "$count" -eq 0 ]]; then
    dotfile_warn "no links emitted for tool '$tool' on $os_key."
  fi
}

append_unique_line() {
  local file="$1" line="$2"
  [[ -e "$file" ]] || : > "$file"
  if grep -qF -- "$line" "$file"; then
    return 0
  fi
  printf '%s\n' "$line" >> "$file"
}
