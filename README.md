# Ben's Dotfiles

## Prerequisites

**Mac:** 

Install Xcode:

`xcode-select --install`

## Install

### 1. Download Nix:

Docs: https://nixos.org/download/

**Mac:** 

`$ sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)`

**Linux:** 

`$ sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon`

### 2. Clone this repo: 

`nix-shell -p git --run "git clone https://github.com/benfeather/dotfiles.git ~/Dotfiles"`

### 4. Generate SOPs key

Copy your SSH keys to:

`~/.ssh`

Create the sops directory:

`mkdir -p ~/.config/sops/age`

Generate the sops keys.txt file:

`nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_benfeather.dev > ~/.config/sops/age/keys.txt"`

Get the public key:

`nix-shell -p ssh-to-age --run "ssh-to-age < ~/.ssh/id_benfeather.dev.pub"`

Create a sops secret file:

`nix-shell -p sops --run "sops secrets.yaml"`

### 5. Initial Setup:

**Mac:**

`sudo nix run nix-darwin --extra-experimental-features "flakes nix-command" -- switch --flake ~/Dotfiles/nix#hostname`

**Linux:**

`sudo nixos-rebuild switch --flake ~/Dotfiles/nix#hostname`