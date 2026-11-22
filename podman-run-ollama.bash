mkdir -p "$(pwd)/ollama_data"

# Select available GPU devices (Bash).
GPU_ARGS=()
OLLAMA_IMAGE=docker.io/ollama/ollama:latest
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
  GPU_ARGS+=(--device nvidia.com/gpu=all)
elif [ -e /dev/kfd ] && [ -d /dev/dri ]; then
  GPU_ARGS+=(--device /dev/kfd --device /dev/dri)
  OLLAMA_IMAGE=docker.io/ollama/ollama:rocm
fi

podman run --detach \
  --pull newer \
  --security-opt label=type:container_runtime_t \
  --replace \
  --restart unless-stopped \
  --group-add keep-groups \
  "${GPU_ARGS[@]}" \
  --env OLLAMA_DEBUG=1 \
  --env OLLAMA_API_KEY="SecureSharedSecret" \
  --env OLLAMA_KEEP_ALIVE=-1 \
  --env OLLAMA_FLASH_ATTENTION=1 \
  --env OLLAMA_NUM_PARALLEL=1 \
  --env OLLAMA_MAX_LOADED_MODELS=2 \
  --env OLLAMA_KV_CACHE_TYPE=q8_0 \
  --env OLLAMA_CONTEXT_LENGTH=65536 \
  --volume "$(pwd)/ollama_data:/root/.ollama:Z" \
  --publish 11434:11434 \
  --name ollama \
  "$OLLAMA_IMAGE"

# Pull a model once before using it in VS Code Continue.
# podman exec ollama ollama pull qwen2.5-coder:7b

# Continue config (e.g. ~/.continue/config.yaml):
# models:
#   - name: Qwen2.5-Coder-7B
#     provider: ollama
#     apiKey: SecureSharedSecret
#     model: qwen2.5-coder:7b
#     apiBase: http://localhost:11434
#     roles:
#       - chat
#       - edit
#     defaultCompletionOptions:
#       contextLength: 8192
#       maxTokens: 2048
#   - name: Autocomplete-Coder
#     provider: ollama
#     apiKey: SecureSharedSecret
#     model: qwen2.5-coder:1.5b
#     apiBase: http://localhost:11434
#     roles:
#       - autocomplete
#     defaultCompletionOptions:
#       contextLength: 2048
#       maxTokens: 256

# OpenCode config (e.g. ~/.config/opencode/opencode.json):
# {
#   "$schema": "https://opencode.ai/config.json",
#   "provider": {
#     "ollama": {
#       "npm": "@ai-sdk/openai-compatible",
#       "name": "Ollama",
#       "options": {
#         "baseURL": "http://localhost:11434/v1",
#         "apiKey": "SecureSharedSecret"
#       },
#       "models": {
#         "qwen2.5-coder:7b": {
#           "name": "Qwen2.5-Coder-7B"
#         },
#         "qwen2.5-coder:1.5b": {
#           "name": "Autocomplete-Coder"
#         }
#       }
#     }
#   },
#   "model": "ollama/qwen2.5-coder:7b"
# }

