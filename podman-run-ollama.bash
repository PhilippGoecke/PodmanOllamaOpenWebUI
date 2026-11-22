set -euo pipefail

DATA_DIR="$(pwd)/ollama_data"
mkdir -p "$DATA_DIR"

# Select the available GPU backend. NVIDIA CDI support is required for the
# nvidia.com/gpu=all device when Podman is used outside Docker Desktop.
GPU_ARGS=()
OLLAMA_IMAGE="docker.io/ollama/ollama:latest"
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
  GPU_ARGS+=(--device nvidia.com/gpu=all)
elif [[ -e /dev/kfd && -d /dev/dri ]]; then
  GPU_ARGS+=(--device /dev/kfd --device /dev/dri)
  OLLAMA_IMAGE="docker.io/ollama/ollama:rocm"
fi

podman run --detach \
  --pull newer \
  --security-opt label=type:container_runtime_t \
  --replace \
  --restart unless-stopped \
  --group-add keep-groups \
  --health-cmd "ollama list >/dev/null 2>&1 || exit 1" \
  --health-interval 30s \
  --health-start-period 20s \
  --health-retries 3 \
  "${GPU_ARGS[@]}" \
  --env OLLAMA_DEBUG=1 \
  --env OLLAMA_KEEP_ALIVE=-1 \
  --env OLLAMA_FLASH_ATTENTION=1 \
  --env OLLAMA_NUM_PARALLEL=1 \
  --env OLLAMA_MAX_LOADED_MODELS=2 \
  --env OLLAMA_KV_CACHE_TYPE=q8_0 \
  --env OLLAMA_CONTEXT_LENGTH=65536 \
  --env OLLAMA_API_KEY="${OLLAMA_API_KEY:-SecureSharedSecret}" \
  --volume "$DATA_DIR:/root/.ollama:Z" \
  --publish 127.0.0.1:11434:11434 \
  --name ollama \
  "$OLLAMA_IMAGE"

# Pull only missing models. This makes the setup safe to rerun.
for model in qwen2.5-coder:7b qwen2.5-coder:1.5b; do
  podman exec ollama ollama list | awk 'NR > 1 {print $1}' | grep -Fxq "$model" \
    || podman exec ollama ollama pull "$model"
done

# Continue config (e.g. ~/.continue/config.yaml):
# models:
#   - name: Qwen2.5-Coder-7B
#     provider: ollama
#     apiKey: ${OLLAMA_API_KEY:-SecureSharedSecret}
#     model: qwen2.5-coder:7b
#     apiBase: http://localhost:11434
#     roles:
#       - chat
#       - edit
#     defaultCompletionOptions:
#       contextLength: 32768
#       maxTokens: 2048
#   - name: Autocomplete-Coder
#     provider: ollama
#     apiKey: ${OLLAMA_API_KEY:-SecureSharedSecret}
#     model: qwen2.5-coder:1.5b
#     apiBase: http://localhost:11434
#     roles:
#       - autocomplete
#     defaultCompletionOptions:
#       contextLength: 8192
#       maxTokens: 256

# OpenCode config (e.g. ~/.config/opencode/opencode.json):
# {
#   "$schema": "https://opencode.ai/config.json",
#   "permission": {
#     "edit": "allow",
#     "patch": "allow",
#     "write": "allow",
#     "multiedit": "allow"
#   },
#   "provider": {
#     "ollama": {
#       "npm": "@ai-sdk/openai-compatible",
#       "name": "Ollama",
#       "options": {
#         "baseURL": "http://localhost:11434/v1",
#         "apiKey": "SecureSharedSecret"
#       },
#       "models": {
#         "qwen3-coder:30b": { "name": "Qwen3-Coder-30B" },
#         "qwen2.5-coder:1.5b": { "name": "Autocomplete-Coder" }
#       }
#     }
#   },
#   "model": "ollama/qwen3-coder:30b"
# }

# Check running models: podman exec ollama ollama ps
podman logs -f ollama
