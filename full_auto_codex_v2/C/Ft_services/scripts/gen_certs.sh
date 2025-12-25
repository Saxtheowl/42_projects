#!/usr/bin/env bash
# Generate self-signed certs for ingress.
set -euo pipefail
CERTS_DIR=${CERTS_DIR:-certs}
CN=${CN:-ft-services.local}
mkdir -p "$CERTS_DIR"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$CERTS_DIR/tls.key" -out "$CERTS_DIR/tls.crt" \
  -subj "/CN=${CN}/O=${CN}" >/dev/null 2>&1
cat > "$CERTS_DIR/secret.yaml" <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: ingress-tls
  namespace: ft-services
type: kubernetes.io/tls
data:
  tls.crt: $(base64 -w0 < "$CERTS_DIR/tls.crt")
  tls.key: $(base64 -w0 < "$CERTS_DIR/tls.key")
YAML
echo "Certs generated in $CERTS_DIR and secret manifest at $CERTS_DIR/secret.yaml" >&2
