#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
SCRIPT="upgrader"
TMP=$(mktemp)

cat > "$TMP" << 'PYEOF'
#!/usr/bin/env python3
import subprocess, sys
from pathlib import Path


def run(cmd, check=True):
    print(f"\n--- {' '.join(cmd)} ---")
    result = subprocess.run(cmd)
    if check and result.returncode != 0:
        print(f"Command failed with exit code {result.returncode}")
        sys.exit(result.returncode)
    return result


def find_aur_helper():
    for h in ["yay", "paru"]:
        if subprocess.run(["which", h], capture_output=True).returncode == 0:
            return h
    return None


def update_aur():
    h = find_aur_helper()
    if h:
        run([h, "-Syu"])
    else:
        print("No AUR helper (yay/paru) found, skipping.")


def update_appimages(dirs):
    imgs = []
    for d in dirs:
        p = Path(d)
        if p.is_dir():
            imgs.extend(p.glob("*.AppImage"))
    if not imgs:
        print("\nNo AppImages found.")
        return
    for a in imgs:
        run([str(a), "--update-check"], check=False)


def main():
    if not sys.platform.startswith("linux"):
        print("Arch Linux only.")
        sys.exit(1)
    run(["sudo", "pacman", "-Syu"])
    update_aur()
    if subprocess.run(["which", "flatpak"], capture_output=True).returncode == 0:
        run(["flatpak", "update", "-y"])
    else:
        print("\nflatpak not installed, skipping.")
    update_appimages([Path.home() / "Applications", Path.home() / ".local/bin"])
    print("\nAll upgrades complete.")


if __name__ == "__main__":
    main()
PYEOF

chmod +x "$TMP"

if [ "$INSTALL_DIR" = "/usr/local/bin" ] && [ ! -w "$INSTALL_DIR" ]; then
  sudo mv "$TMP" "$INSTALL_DIR/$SCRIPT"
else
  mv "$TMP" "$INSTALL_DIR/$SCRIPT"
fi

echo "Installed upgrader to $INSTALL_DIR/$SCRIPT"
echo "Run it with: upgrader"
