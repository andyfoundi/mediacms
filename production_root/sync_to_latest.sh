# Sync production to the latest fd branch, restore secrets, restart the stack.
# Place in the home directory, next to mediacms/ and secrets/.
set -euo pipefail

cd "$HOME/mediacms"

git fetch origin
git checkout fd
git reset --hard origin/fd

# Both files are gitignored; restore them in case an update removed them.
cp "$HOME/secrets/local_settings.py" deploy/docker/local_settings.py
cp "$HOME/secrets/env" .env

# Recreate so uwsgi/celery reload code and migrations re-run prestart.sh.
docker compose --env-file .env up -d --force-recreate
