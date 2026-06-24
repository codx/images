#!/usr/bin/env bash
# Regenerate the Recipes section in README.md from pages/*.md
set -euo pipefail

cd "$(dirname "$0")" || exit 1

BEGIN='<!-- BEGIN RECIPES -->'
END='<!-- END RECIPES -->'

# Map page filenames to section headers
declare -A headers=(
  [dbug.md]="Shell shortcuts"
  [dbug-capture.md]="Packet capture"
  [dbug-dns.md]="DNS"
  [dbug-http.md]="HTTP / gRPC / WebSocket"
  [dbug-net.md]="Network diagnostics"
  [dbug-tls.md]="TLS / certificates"
  [dbug-k8s.md]="Kubernetes"
)

# Page ordering
order=(dbug.md dbug-capture.md dbug-dns.md dbug-http.md dbug-net.md dbug-tls.md dbug-k8s.md)

# Convert a tldr page to a README section
render_page() {
  local file="$1" header="$2"
  echo "### ${header}"
  echo ""
  echo '```bash'
  while IFS= read -r line; do
    [[ "$line" =~ ^#\  ]] && continue
    [[ "$line" =~ ^\> ]] && continue
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ ^-\  ]]; then
      desc="${line#- }"
      desc="${desc%:}"
      echo "# ${desc}"
    elif [[ "$line" =~ ^\` ]]; then
      cmd="${line//\`/}"
      cmd=$(echo "$cmd" | sed -E 's/\{\{([^}]*)\}\}/\1/g')
      echo "$cmd"
    fi
  done < "pages/$file"
  echo '```'
  echo ""
}

# Splice: keep everything before BEGIN and after END, insert generated recipes between
if ! grep -q "$BEGIN" README.md; then
  echo "ERROR: missing '$BEGIN' marker in README.md" >&2
  exit 1
fi

{
  # Print everything up to and including BEGIN marker
  sed -n "1,/^${BEGIN}$/p" README.md

  # Generate recipes from pages
  for page in "${order[@]}"; do
    [[ -f "pages/$page" ]] || continue
    render_page "$page" "${headers["$page"]}"
  done

  # Print everything from END marker onward
  sed -n "/^${END}$/,\$p" README.md
} > README.md.tmp

mv README.md.tmp README.md
echo "README.md recipes synced from pages/"
