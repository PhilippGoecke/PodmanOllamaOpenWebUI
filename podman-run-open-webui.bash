set -euo pipefail

readonly data_dir="${PWD}/webui_data"
mkdir -p "$data_dir"

podman run --detach --replace --pull newer \
  --name open-webui \
  --restart always \
  --publish 8080:8080 \
  --env OLLAMA_BASE_URL=http://host.containers.internal:11434 \
  --env OLLAMA_API_KEY=SecureSharedSecret \
  --env WEBUI_SECRET_KEY=change-me-to-a-long-random-secret \
  --env ENABLE_SIGNUP=false \
  --env WEBUI_AUTH=true \
  --env WEBUI_ADMIN_EMAIL=admin@openwebui.local \
  --env WEBUI_ADMIN_PASSWORD=SecurePassword123 \
  --volume "$data_dir:/app/backend/data" \
  ghcr.io/open-webui/open-webui:main
