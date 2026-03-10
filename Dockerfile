FROM debian:stable-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends openssl \
 && rm -rf /var/lib/apt/lists/*

COPY scripts/generate-entra-certificate.sh   /usr/local/bin/generate-entra-certificate
COPY scripts/save-entra-certificate.sh       /usr/local/bin/save-entra-certificate
COPY scripts/parse-entra-certificate-args.sh /usr/local/bin/parse-entra-certificate-args

RUN chmod +x /usr/local/bin/generate-entra-certificate \
             /usr/local/bin/save-entra-certificate \
             /usr/local/bin/parse-entra-certificate-args

RUN mkdir -p /inputs /outputs

ENTRYPOINT ["/bin/bash", "-c", "\
  for JSON in /inputs/*.json; do \
    NAME=$(basename \"$JSON\" .json); \
    parse-entra-certificate-args --json \"$JSON\" \
      | xargs generate-entra-certificate \
      | save-entra-certificate --name \"$NAME\" --outDir /outputs; \
  done"]