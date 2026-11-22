mkdir -p "$(pwd)/ollama_data"

podman run --detach \
  --pull newer \
  --replace \
  --restart unless-stopped \
  --device nvidia.com/gpu=all \
  --env OLLAMA_DEBUG=1 \
  --env OLLAMA_API_KEY="SecureSharedSecret" \
  --env OLLAMA_KEEP_ALIVE=24h \
  --env OLLAMA_FLASH_ATTENTION=1 \
  --env OLLAMA_NUM_PARALLEL=1 \
  --env OLLAMA_MAX_LOADED_MODELS=1 \
  --volume "$(pwd)/ollama_data:/root/.ollama:Z" \
  --publish 127.0.0.1:11434:11434 \
  --name ollama \
  docker.io/ollama/ollama:latest

# Pull a model once before using it in VS Code Continue.
# podman exec ollama ollama pull qwen2.5-coder:7b

# Continue config (e.g. ~/.continue/config.yaml):
# models:
#   - title: Qwen 2.5 Coder 7B
#     provider: ollama
#     model: qwen2.5-coder:7b
#     apiBase: http://127.0.0.1:11434
