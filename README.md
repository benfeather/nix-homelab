# NixOS HomeLab

## Install

### Edit the configuration fie:

`sudo nano /etc/nixos/configuration.nix`

```
services.openssh.enable = true;

environment.systemPackages = with pkgs; [
	git
];
```

### Rebuild the system:

`sudo nixos-rebuild switch`

### Get SSH keys

`ssh-keygen -t ed25519`

`curl https://github.com/benfeather.keys -o ~/.ssh/authorized_keys`

### Clone this repo: 

`sudo mkdir /config`

`sudo chown -R 1000:nobody /config`

`git clone https://github.com/benfeather/nix-homelab.git /config`

`cp /etc/nixos/hardware-configuration.nix /config/nixos`

### Use the new config

`sudo nixos-rebuild switch --flake /config#hydra`
