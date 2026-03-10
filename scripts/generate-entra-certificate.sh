#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --commonName <CN> --days <days> --password <password> [--keyLength <bits>]" >&2
  exit 1
}

COMMON_NAME=""; DAYS=""; PASSWORD=""; KEY_LENGTH=2048

while [[ $# -gt 0 ]]; do
  case "$1" in
    --commonName) COMMON_NAME="$2"; shift 2 ;;
    --days)       DAYS="$2";        shift 2 ;;
    --password)   PASSWORD="$2";    shift 2 ;;
    --keyLength)  KEY_LENGTH="$2";  shift 2 ;;
    *) usage ;;
  esac
done

[[ -z "$COMMON_NAME" || -z "$DAYS" || -z "$PASSWORD" ]] && usage
[[ "$DAYS" =~ ^[0-9]+$ ]] || { echo "Error: days must be a positive integer" >&2; exit 1; }
[[ "$DAYS" -gt 0 ]]       || { echo "Error: days must be greater than 0" >&2; exit 1; }

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

openssl genrsa -out "$WORK_DIR/key.pem" "$KEY_LENGTH" 2>/dev/null

openssl req -new -x509 \
  -key  "$WORK_DIR/key.pem" \
  -out  "$WORK_DIR/cert.pem" \
  -subj "/CN=${COMMON_NAME}" \
  -days "$DAYS" \
  -sha256 \
  -addext "basicConstraints=critical,CA:FALSE" \
  -addext "extendedKeyUsage=clientAuth" \
  -addext "keyUsage=critical,digitalSignature" \
  2>/dev/null

openssl pkcs12 -export \
  -out      "$WORK_DIR/cert.pfx" \
  -inkey    "$WORK_DIR/key.pem" \
  -in       "$WORK_DIR/cert.pem" \
  -password "pass:${PASSWORD}" \
  2>/dev/null

openssl x509 -in "$WORK_DIR/cert.pem" -outform DER -out "$WORK_DIR/cert.cer" 2>/dev/null

PFX_B64=$(base64 -w 0 < "$WORK_DIR/cert.pfx" 2>/dev/null || base64 < "$WORK_DIR/cert.pfx")
CER_B64=$(base64 -w 0 < "$WORK_DIR/cert.cer" 2>/dev/null || base64 < "$WORK_DIR/cert.cer")
PWD_B64=$(printf '%s' "$PASSWORD" | base64 -w 0 2>/dev/null || printf '%s' "$PASSWORD" | base64)

printf '{\n'
printf '  "pfx_b64": "%s",\n'          "$PFX_B64"
printf '  "pfx_password_b64": "%s",\n' "$PWD_B64"
printf '  "cer_b64": "%s"\n'           "$CER_B64"
printf '}\n'