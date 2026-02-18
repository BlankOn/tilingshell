#!/bin/sh
EXT_NAME="tilingshell@ferrarodomenico.com"
SRC="/usr/share/gnome-shell/extensions/$EXT_NAME"
DEST="$HOME/.local/share/gnome-shell/extensions/$EXT_NAME"
VERSION_FILE="$DEST/.installed-version"
AUTOSTART_FILE="$HOME/.config/autostart/tilingshell-extension-update.desktop"

# If system source is removed, clean up and exit
if [ ! -d "$SRC" ]; then
    gnome-extensions disable "$EXT_NAME" 2>/dev/null || true
    rm -rf "$DEST"
    rm -f "$AUTOSTART_FILE"
    exit 0
fi

# Get installed package version
PKG_VERSION=$(dpkg-query -W -f='${Version}' tilingshell-gnome-shell-extension 2>/dev/null || echo "unknown")

# Check if already up to date
if [ -f "$VERSION_FILE" ] && [ "$(cat "$VERSION_FILE")" = "$PKG_VERSION" ]; then
    exit 0
fi

# Install or update user copy
mkdir -p "$DEST"
cp -r "$SRC"/* "$DEST"/
echo "$PKG_VERSION" > "$VERSION_FILE"
gnome-extensions enable "$EXT_NAME" 2>/dev/null || true
