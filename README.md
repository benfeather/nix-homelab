# NixOS HomeLab

## Install

### 1. Install Nix:

`$ sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon`

### 2. Clone this repo: 

`sudo rm -R /etc/nixos`
`nix-shell -p git --run "git clone https://github.com/benfeather/nix-homelab.git /etc/nixos"`
`nixos-generate-config`

### 3. Initial Setup:

`sudo nixos-rebuild switch --flake /etc/nixos`