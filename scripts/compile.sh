#!/usr/bin/env bash
# Compiles the .typ files listed in src/content/categories/*.json to the
# matching path under public/pdfs/<category>/. Only files referenced by a
# category JSON get compiled — everything else in typst-src/ (templates,
# shared library files, etc.) is left alone.
#
# Usage:
#   ./scripts/compile.sh
#
# Requires the `typst` CLI (https://github.com/typst/typst#installation)
# and python3, both on PATH.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT/typst-src"
OUT_DIR="$ROOT/public/pdfs"
CATS_DIR="$ROOT/src/content/categories"
FONT_DIR="$ROOT/fonts"

for bin in typst python3; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "error: '$bin' not found on PATH." >&2
    exit 1
  fi
done

if [ ! -d "$CATS_DIR" ]; then
  echo "error: no category files found at src/content/categories/" >&2
  exit 1
fi

# Parses one category JSON file and prints one line per doc:
#   source<TAB>slug<TAB>title
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

compiled=0
for cat_file in "$CATS_DIR"/*.json; do
  [ -e "$cat_file" ] || continue
  category="$(basename "$cat_file" .json)"
  echo "== $category =="

  referenced=()
  while IFS=$'\t' read -r source slug title; do
    typ_path="$SRC_DIR/$category/$source"
    out_path="$OUT_DIR/$category/$slug.pdf"
    referenced+=("$source")

    if [ ! -f "$typ_path" ]; then
      echo "  ! skipping \"$title\": typst-src/$category/$source not found" >&2
      continue
    fi

    mkdir -p "$(dirname "$out_path")"
    echo "  compiling  $category/$source  ->  public/pdfs/$category/$slug.pdf"
    typst compile --font-path "$FONT_DIR" "$typ_path" "$out_path"
    compiled=$((compiled + 1))
  done < <(parse_docs "$cat_file")

  # Informational only: point out .typ files in this category's folder that
  # no doc entry references (expected for template/library files, but also
  # catches "I wrote a new doc and forgot to add it to the JSON").
  if [ -d "$SRC_DIR/$category" ]; then
    while IFS= read -r -d '' typ; do
      name="$(basename "$typ")"
      found=0
      for r in "${referenced[@]:-}"; do
        [ "$r" = "$name" ] && found=1 && break
      done
      [ "$found" -eq 0 ] && echo "  · not referenced by any doc: $category/$name"
    done < <(find "$SRC_DIR/$category" -maxdepth 1 -type f -name '*.typ' -print0)
  fi
done

echo "done: compiled $compiled file(s)"
