# NixOS HomeLab

## Install

### 1. Clone this repo: 

`nix-shell -p git --run "git clone https://github.com/benfeather/nix-homelab.git ~/homelab"`

### 2. Initial Setup:

`sudo nixos-rebuild switch --flake ~/homelab#hydra`