#!/usr/bin/env bash
#
#  fix_socialapp_settings.sh
#  -------------------------
#  Copy the inline SAML-Configuration JSON into SocialApp.settings
#  and pretty-print the resulting settings so you can verify them.
#
#  Usage examples
#    ./fix_socialapp_settings.sh                      # defaults: mediacms_web_1 / google-workspace
#    ./fix_socialapp_settings.sh mediacms_web_1 acme-idp
#    ./fix_socialapp_settings.sh mediacms_web_1 acme-idp saml
#

# ─── configurable CLI params ───────────────────────────────────────────
CONTAINER=${1:-mediacms-web-1}     # Docker container name / ID
CLIENT_ID=${2:-foundi-info}   # SocialApp.client_id
PROVIDER=${3:-saml}                # Provider (normally "saml")
# ───────────────────────────────────────────────────────────────────────

docker exec -i "$CONTAINER" bash <<EOF
set -e

python manage.py shell <<'PY'
from allauth.socialaccount.models import SocialApp
from saml_auth.models import SAMLConfiguration
import json, sys, textwrap

provider  = "$PROVIDER"
client_id = "$CLIENT_ID"

try:
    app = SocialApp.objects.get(provider=provider, client_id=client_id)
except SocialApp.DoesNotExist:
    sys.exit(f"❌  SocialApp provider={provider!r} client_id={client_id!r} not found")

cfg = app.saml_configurations.first()
if not cfg:
    sys.exit("❌  No inline SAML Configuration attached to that SocialApp")

# Sync the inline JSON into SocialApp.settings
app.settings = cfg.saml_provider_settings
app.save(update_fields=["settings"])

pretty_json = json.dumps(app.settings, indent=2, sort_keys=True)
print("\\n✅  Copied inline SAML JSON into SocialApp.settings for", client_id)
print("── Final settings JSON ───────────────────────────────────────────")
print(textwrap.indent(pretty_json, "  "))
print("──────────────────────────────────────────────────────────────────")
PY
EOF
