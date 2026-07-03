mkdir -p $(pwd)/webui_data

podman run -d -p 8080:8080 \
  -e OLLAMA_BASE_URL=http://host.containers.internal:11434 -e OLLAMA_TOKEN=SecureSharedSecret \
  -e WEBUI_SECRET_KEY=change-me-to-a-long-random-secret -e ENABLE_SIGNUP=false \
  -e WEBUI_ADMIN_EMAIL="admin@openwebui.local" \
  -e WEBUI_ADMIN_PASSWORD="SecurePassword123" \
  -v $(pwd)/webui_data:/app/backend/data \
  -e WEBUI_AUTH=True \
  --name open-webui --restart always ghcr.io/open-webui/open-webui:main
