#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --name <filename-without-extension> [--outDir <directory>] [--json <path-to-json>]" >&2
  exit 1
}

JSON=""; NAME=""; OUT_DIR="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)   JSON="$2";    shift 2 ;;
    --name)   NAME="$2";    shift 2 ;;
    --outDir) OUT_DIR="$2"; shift 2 ;;
    *) usage ;;
  esac
done

[[ -z "$NAME" ]] && usage

if [[ -n "$JSON" ]]; then
  [[ -f "$JSON" ]] || { echo "Error: file not found: $JSON" >&2; exit 1; }
  INPUT=$(cat "$JSON")
else
  INPUT=$(cat)
fi

mkdir -p "$OUT_DIR"

PFX_B64=$(grep -o '"pfx_b64": *"[^"]*"' <<< "$INPUT" | grep -o '"[^"]*"$' | tr -d '"')
CER_B64=$(grep -o '"cer_b64": *"[^"]*"' <<< "$INPUT" | grep -o '"[^"]*"$' | tr -d '"')
PWD_B64=$(grep -o '"pfx_password_b64": *"[^"]*"' <<< "$INPUT" | grep -o '"[^"]*"$' | tr -d '"')

fold -w 64 <<< "$PFX_B64" | openssl base64 -d > "$OUT_DIR/${NAME}.pfx"
fold -w 64 <<< "$CER_B64" | openssl base64 -d > "$OUT_DIR/${NAME}.cer"
fold -w 64 <<< "$PWD_B64" | openssl base64 -d > "$OUT_DIR/${NAME}.password.txt"
echo "$PFX_B64" > "$OUT_DIR/${NAME}.pfx.base64.txt"

echo "Saved: $OUT_DIR/${NAME}.pfx"
echo "Saved: $OUT_DIR/${NAME}.pfx.base64.txt"
echo "Saved: $OUT_DIR/${NAME}.cer"
echo "Saved: $OUT_DIR/${NAME}.password.txt"