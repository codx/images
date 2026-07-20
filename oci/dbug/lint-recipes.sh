#!/usr/bin/env bash
# Lint guard: every command referenced in pages/*.md must actually exist in the
# image. The pages are the source of truth for the README recipes and the tldr
# cheatsheets shipped inside the container, so a recipe naming a tool that isn't
# installed fails with "command not found" both in the rendered README and at
# runtime. This catches that drift (e.g. swaks/prettyping/k9s) without needing
# to build the image.
#
# A referenced command is considered resolved if it is any of:
#   1. a package listed in apko.yaml,
#   2. a binary provided by a package in apko.yaml under a different name
#      (the PROVIDES map below — only credited while its package is present),
#   3. a fish function or abbreviation defined in melange.yaml (the dotfiles),
#   4. an intentionally-external driver tool (the EXTERNAL list below).
set -euo pipefail

cd "$(dirname "$0")" || exit 1

# Binaries whose providing package has a different name. Each entry is only
# honored while its package is still in apko.yaml, so dropping the package
# re-flags any recipe that used the binary.
declare -A PROVIDES=(
  [dig]=bind-tools
  [drill]=ldns
  [trip]=trippy
  [conntrack]=conntrack-tools
  [nc]=netcat-openbsd
  [rg]=ripgrep
  [ping]=iputils
  [hx]=helix
)

# Tools that are intentionally NOT in the image: they drive the image from the
# host (the k8s recipes invoke kubectl to launch/attach the dbug pod).
EXTERNAL=" kubectl "

# 1. Packages declared in apko.yaml (the `packages:` block only).
pkgs=$(awk '
  /^  packages:/ { inpkg=1; next }
  /^[^ ]/        { inpkg=0 }
  inpkg && /^    - / {
    gsub(/^    - /, ""); gsub(/#.*/, ""); gsub(/@local.*/, "")
    gsub(/[ \t]+$/, "")
    if ($0 != "") print
  }
' apko.yaml)

# 3. Fish functions and abbreviations defined in the dotfiles.
funcs=$(grep -oE 'function [A-Za-z0-9_-]+' melange.yaml | awk '{print $2}')
# The abbr name is the token after the first standalone `--` (flags use the
# attached `--flag=val` form, so the first bare `--` is always the separator;
# a later `--` may appear inside the expansion value, e.g. `rg -i. -- "%"`).
abbrs=$(grep -E 'abbr -a' melange.yaml \
  | awk '{ for (i=1;i<NF;i++) if ($i=="--") { print $(i+1); break } }')

resolved=$(printf '%s\n%s\n%s\n' "$pkgs" "$funcs" "$abbrs" | sort -u)

# Commands referenced by recipes: the leading token of each backticked line.
# The backticks below are literal grep/sed pattern text, not command substitution.
# shellcheck disable=SC2016
commands=$(grep -rhoE '^`[^`]+`' pages/*.md | sed -E 's/^`//; s/`$//' | awk '{print $1}' | sort -u)

missing=()
while IFS= read -r cmd; do
  [[ -z "$cmd" ]] && continue
  if grep -qxF "$cmd" <<<"$resolved"; then
    continue
  fi
  if [[ -n "${PROVIDES["$cmd"]:-}" ]] && grep -qxF "${PROVIDES["$cmd"]}" <<<"$pkgs"; then
    continue
  fi
  if [[ "$EXTERNAL" == *" $cmd "* ]]; then
    continue
  fi
  missing+=("$cmd")
done <<<"$commands"

if (( "${#missing[@]}" > 0 )); then
  echo "ERROR: recipe commands not resolvable in the image:" >&2
  for cmd in "${missing[@]}"; do
    file=$(grep -rlE "^\`$cmd( |\`)" pages/*.md | head -1)
    echo "  - $cmd  (${file:-pages/?})" >&2
  done
  echo >&2
  echo "Fix: add the package to apko.yaml, define a fish function/abbr in" >&2
  echo "melange.yaml, or remove the recipe. If it's a host-side tool, add it" >&2
  echo "to EXTERNAL in $(basename "$0"); if pkg name != binary, add to PROVIDES." >&2
  exit 1
fi

echo "OK: all recipe commands resolve ($(wc -w <<<"$commands" | tr -d ' ') checked)"
