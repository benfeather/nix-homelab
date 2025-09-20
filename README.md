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

### Get a SOPs age key

`mkdir -p ~/.config/sops/age`

`nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"`

`nix-shell -p ssh-to-age --run 'cat ~/.ssh/id_ed25519.pub | ssh-to-age'`

### Clone this repo: 

`sudo mkdir /mnt/unraid/homelab`

`sudo chown -R 1000:nobody /mnt/unraid/homelab`

`git clone https://github.com/benfeather/nix-homelab.git /mnt/unraid/homelab`

### Use the new config

`sudo nixos-rebuild switch --flake /mnt/unraid/homelab#nixos`
