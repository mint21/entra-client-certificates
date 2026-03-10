#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --json <path-to-json>" >&2
  exit 1
}

JSON=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON="$2"; shift 2 ;;
    *) usage ;;
  esac
done

[[ -z "$JSON" ]] && usage
[[ -f "$JSON" ]] || { echo "Error: file not found: $JSON" >&2; exit 1; }

extract() {
  grep -o "\"$1\": *\"[^\"]*\"" "$JSON" | grep -o '"[^"]*"$' | tr -d '"'
}

extract_num() {
  grep -o "\"$1\": *[0-9]*" "$JSON" | grep -o '[0-9]*$'
}

COMMON_NAME=$(extract "commonName")
DAYS=$(extract_num "days")
PASSWORD=$(extract "password")
KEY_LENGTH=$(extract_num "keyLength")

[[ -z "$COMMON_NAME" ]] && { echo "Error: missing commonName"  >&2; exit 1; }
[[ -z "$DAYS"        ]] && { echo "Error: missing days"        >&2; exit 1; }
[[ -z "$PASSWORD"    ]] && { echo "Error: missing password"    >&2; exit 1; }

ARGS="--commonName \"$COMMON_NAME\" --days $DAYS --password \"$PASSWORD\""
[[ -n "$KEY_LENGTH" ]] && ARGS="$ARGS --keyLength $KEY_LENGTH"

echo "$ARGS"