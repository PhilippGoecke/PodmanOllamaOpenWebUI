# PodmanOllamaOpenWebUI
Podman Ollama OpenWebUI

bash podman-run-ollama.bash  
bash podman-run-open-webui.bash  
ollama ps  

```bash
sed -i 's/ main$/ main contrib non-free/' /etc/apt/sources.list
apt update
apt install tmux htop podman git curl
apt install -y linux-headers-$(uname -r) nvidia-driver firmware-misc-nonfree nvidia-smi nvidia-cuda-toolkit

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt update
apt install -y nvidia-container-toolkit

#nvidia-ctk runtime configure --runtime=podman
nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

curl -fsSL https://github.com/ollama/ollama/releases/download/v0.30.11/ollama-linux-amd64.tar.zst | tar x --zstd -C /usr/local/
chmod +x /usr/local/bin/ollama
```
