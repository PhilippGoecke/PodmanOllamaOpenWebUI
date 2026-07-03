mkdir -p $(pwd)/ollama_data

podman run -d --device nvidia.com/gpu=all -e OLLAMA_API_KEY="SecureSharedSecret" -v $(pwd)/ollama_data:/root/.ollama -p 11434:11434 --name ollama docker.io/ollama/ollama:latest
