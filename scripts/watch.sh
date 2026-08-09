#!/usr/bin/env bash
# Watches the .typ files listed in src/content/categories/*.json and
# recompiles each to public/pdfs/<category>/ on save. Runs one `typst
# watch` process per doc in the background. Re-run this script (Ctrl+C
# first) after adding a new doc entry to a category JSON file.
#
# Usage:
#   ./scripts/watch.sh
#
# Requires the `typst` CLI and python3, both on PATH.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT/typst-src"
OUT_DIR="$ROOT/public/pdfs"
CATS_DIR="$ROOT/src/content/categories"

for bin in typst python3; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "error: '$bin' not found on PATH." >&2
    exit 1
  fi
done

parse_docs() {
  python3 - "$1" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
for doc in data["docs"]:
    source = doc["source"]
    slug = doc.get("slug") or source.rsplit(".", 1)[0]
    print(f"{source}\t{slug}\t{doc['title']}")
PY
}

pids=()
cleanup() {
  echo
  echo "stopping watchers..."
  for pid in "${pids[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT INT TERM

count=0
for cat_file in "$CATS_DIR"/*.json; do
  [ -e "$cat_file" ] || continue
  category="$(basename "$cat_file" .json)"

  while IFS=$'\t' read -r source slug title; do
    typ_path="$SRC_DIR/$category/$source"
    out_path="$OUT_DIR/$category/$slug.pdf"

    if [ ! -f "$typ_path" ]; then
      echo "! skipping \"$title\": typst-src/$category/$source not found" >&2
      continue
    fi

    mkdir -p "$(dirname "$out_path")"
    echo "watching  $category/$source  ->  public/pdfs/$category/$slug.pdf"
    typst watch --font-path "$ROOT/fonts" "$typ_path" --output "$out_path" &
    pids+=("$!")
    count=$((count + 1))
  done < <(parse_docs "$cat_file")
done

if [ "$count" -eq 0 ]; then
  echo "no doc entries found in src/content/categories/*.json"
  exit 0
fi

echo "watching $count file(s), press Ctrl+C to stop"
wait
