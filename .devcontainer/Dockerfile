FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && apt-get install -y \
    curl unzip screen tmux jq \
    && rm -rf /var/lib/apt/lists/*

USER vscode
WORKDIR /home/vscode
