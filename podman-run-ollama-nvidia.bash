mkdir -p $(pwd)/ollama_data

podman run --detach --pull newer -e OLLAMA_DEBUG=1 --replace --device nvidia.com/gpu=all --env OLLAMA_API_KEY="SecureSharedSecret" --volume $(pwd)/ollama_data:/root/.ollama --publish 11434:11434 --name ollama docker.io/ollama/ollama:latest
