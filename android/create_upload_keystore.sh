#!/usr/bin/env bash
# Create a new Play upload keystore + PEM certificate (after Google approves upload key reset).
# Docs: https://support.google.com/googleplay/android-developer/answer/9842756
#
# Run from repo root:  ./android/create_upload_keystore.sh
# Or:                  cd android && ./create_upload_keystore.sh
#
# You will be prompted for keystore password, key password, and certificate fields (name/org).

set -euo pipefail
cd "$(dirname "$0")"

KEYSTORE="upload-keystore.jks"
ALIAS="upload"
PEM="upload_certificate.pem"

if [[ -f "$KEYSTORE" ]]; then
  echo "Abort: $KEYSTORE already exists. Remove or rename it first."
  exit 1
fi

echo ">>> Generating upload keystore ($KEYSTORE) — RSA 2048, 10000 days"
keytool -genkeypair -v \
  -storetype PKCS12 \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias "$ALIAS" \
  -keystore "$KEYSTORE"

echo ""
echo ">>> Exporting public certificate ($PEM) for Play Console"
keytool -export -rfc \
  -keystore "$KEYSTORE" \
  -alias "$ALIAS" \
  -file "$PEM"

echo ""
echo "Done."
echo "1. In Play Console: complete upload key reset and submit $PEM when asked."
echo "2. Copy key.properties.template to key.properties and fill storePassword / keyPassword."
echo "3. flutter build appbundle --release"
