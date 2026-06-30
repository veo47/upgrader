# upgrader

Python script to upgrade Arch Linux: pacman, AUR, flatpak, and AppImages.

## Install

```bash
curl -sfL https://raw.githubusercontent.com/veo47/upgrader/main/install.sh | sh
```

## Usage

```bash
upgrader
```

## What it does

1. `sudo pacman -Syu` — official packages
2. `yay -Syu` or `paru -Syu` — AUR packages
3. `flatpak update -y` — flatpak apps
4. `--update-check` on AppImages in `~/Applications` and `~/.local/bin`
