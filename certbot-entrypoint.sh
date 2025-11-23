#!/bin/sh
set -eu

WEBROOT_BASE="/var/www"
DOMAINS_FILE=".certbot-domains"

CERTBOT_ARGS="--non-interactive --agree-tos --register-unsafely-without-email"
if [ -n "${CERTBOT_EMAIL:-}" ]; then
  CERTBOT_ARGS="$CERTBOT_ARGS -m $CERTBOT_EMAIL"
fi
if [ "${USE_STAGING:-}" = "true" ]; then
  CERTBOT_ARGS="$CERTBOT_ARGS --staging"
fi

# --- FUNCTIONS ---

# parse_domains <file>
# Reads a domains file and outputs space-separated valid domains.
# Handles CRLF, blank lines, and inline/whole-line # comments.
parse_domains() {
  awk '{ i=index($0,"#"); if(i>0) $0=substr($0,1,i-1); gsub(/\r/,""); gsub(/^[ \011]+/,""); gsub(/[ \011]+$/,""); if(length($0)>0) print $0 }' "$1";
}

# --- MAIN LOOP ---
echo "Scanning $WEBROOT_BASE ..."
for dir in "$WEBROOT_BASE"/*; do
  [ -d "$dir" ] || continue
  cfg="$dir/$DOMAINS_FILE"

  if [ ! -f "$cfg" ]; then
    echo "→ Skipping $(basename "$dir"): no $DOMAINS_FILE"
    continue
  fi

  domains=$(parse_domains "$cfg")
  set -- $domains || true

  if [ $# -eq 0 ]; then
    echo "→ Skipping $(basename "$dir"): $DOMAINS_FILE has no domains after parsing"
    continue
  fi

  dargs=
  for d in "$@"; do
    dargs="$dargs -d $d"
  done

  echo "Requesting/updating cert for: $* (webroot=$dir)"
  certbot certonly --webroot \
    --keep-until-expiring --expand \
    -w "$dir" \
    $dargs \
    $CERTBOT_ARGS
done

echo "Starting renewal loop"
while true; do
  certbot renew --quiet --deploy-hook "echo Certificate renewed at $(date)"
  sleep 12h
done
