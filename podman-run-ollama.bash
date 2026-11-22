mkdir -p "$(pwd)/ollama_data"

# Select available GPU devices (Bash).
GPU_ARGS=()
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
  GPU_ARGS+=(--device nvidia.com/gpu=all)
elif [ -e /dev/kfd ] && [ -d /dev/dri ]; then
  GPU_ARGS+=(--device /dev/kfd --device /dev/dri)
fi

podman run --detach \
  --pull newer \
  --replace \
  --restart unless-stopped \
  "${GPU_ARGS[@]}" \
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
