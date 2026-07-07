mkdir -p $(pwd)/ollama_data

podman run --detach --pull newer -e OLLAMA_DEBUG=1 --security-opt label=type:container_runtime_t --replace --group-add keep-groups --device /dev/kfd --device /dev/dri -e OLLAMA_API_KEY="SecureSharedSecret" -v $(pwd)/ollama_data:/root/.ollama --publish 11434:11434 --name ollama docker.io/ollama/ollama:rocm
