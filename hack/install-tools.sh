# These tools are required for setting up for OCI VM to act as self hosted GPU runner.
# This script is intended to be run as a startup script when creating the VM.

#!/bin/bash
set -eux

sudo apt-get update -y
sudo apt-get upgrade -y

# -------------------------------
# Install build tools & make
# -------------------------------
sudo apt-get install -y build-essential make git curl wget apt-transport-https ca-certificates gnupg lsb-release

# -------------------------------
# Install NVIDIA Container Toolkit
# -------------------------------
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update -y

export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
sudo apt-get install -y \
    nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}

# Install NVIDIA Driver
sudo apt update
sudo apt install nvidia-driver-535 -y
sudo apt install nvidia-utils-535

## Privilaged access for docker to make sure Kind can access GPU resources
alias docker="sudo docker"

# Verify installs
echo "✅ Installed versions:"
sudo docker --version
nvidia-ctk --version
kubectl version --client=true --output=yaml

echo "🎉 Setup complete!"

# -------------------------------
# Test: Verify Docker GPU Access
# -------------------------------
echo "🔎 Testing Docker GPU access..."
sudo docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi || {
  echo "❌ Docker GPU access failed!"
  exit 1
}
echo "✅ Docker GPU access verified!"
