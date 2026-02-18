# Debian Packaging for Tiling Shell GNOME Extension

## Context

Tiling Shell (`tilingshell@ferrarodomenico.com`) is a GNOME Shell extension written in TypeScript that provides advanced tiling window management. It needs to be repackaged as a Debian package using the same two-stage user-space deployment pattern as `praya@blankonlinux.id`: system-wide installation + per-user autostart-based deployment.

## Files to Create

All files go under `/home/herpiko/src/tilingshell/debian/`:

### 1. `debian/source/format`
```
3.0 (native)
```

### 2. `debian/control`
- **Source**: `tilingshell-gnome-shell-extension`
- **Build-Depends**: `debhelper-compat (= 13), nodejs, npm, libglib2.0-dev-bin`
  - `nodejs` + `npm` for TypeScript build (esbuild)
  - `libglib2.0-dev-bin` for `glib-compile-schemas` and `glib-compile-resources`
- **Package**: `tilingshell-gnome-shell-extension`
- **Architecture**: all
- **Depends**: `gnome-shell (>= 45~), dconf-cli, ${misc:Depends}`

### 3. `debian/changelog`
- Initial release `17.3-1` targeting `verbeek`

### 4. `debian/copyright`
- GPL v2.0, upstream author Domenico Ferraro, repackager BlankOn Linux

### 5. `debian/rules`
- **`override_dh_auto_build`**: Run `npm install && npm run build` (builds dist/ from TypeScript source)
- **`override_dh_auto_install`**: Install dist/ contents to `/usr/share/gnome-shell/extensions/tilingshell@ferrarodomenico.com/` using recursive copy (dist/ contains many generated JS files, schemas, icons, locale, resources)
  - Install dconf settings files
  - Install per-user update script to `/usr/lib/tilingshell-extension/`
  - Install autostart desktop file to `/etc/skel/.config/autostart/`

### 6. `debian/dconf/db/local.d/00-tilingshell-global-behaviours`
- Enable extension globally: `enabled-extensions` includes `tilingshell@ferrarodomenico.com`

### 7. `debian/dconf/profile/user`
- Same as praya: `user-db:user` + `system-db:local`

### 8. `debian/postinst`
- Run `dconf update`
- Deploy autostart desktop file to all existing users (`/home/*/`) with uid >= 1000

### 9. `debian/postrm`
- Run `dconf update`
- Remove autostart desktop file from all existing users

### 10. `debian/tilingshell-update-user.sh`
- Per-user update script (runs on login via autostart)
- Copies extension from `/usr/share/gnome-shell/extensions/tilingshell@ferrarodomenico.com/` to `~/.local/share/gnome-shell/extensions/tilingshell@ferrarodomenico.com/`
- Tracks version with `.installed-version` file
- Cleans up if system source is removed
- Enables extension via `gnome-extensions enable`

### 11. `debian/tilingshell-extension-update.desktop`
- Autostart entry that runs the user update script on login

## Key Differences from Praya

| Aspect | Praya | Tiling Shell |
|--------|-------|-------------|
| Build step | None (pure JS) | `npm install && npm run build` |
| Install method | Individual `install -m 644` per file | Recursive copy of `dist/` directory |
| Build-Depends | Only debhelper | debhelper + nodejs + npm + libglib2.0-dev-bin |
| Extension UUID | `praya@blankonlinux.id` | `tilingshell@ferrarodomenico.com` |
| Package name | `praya-gnome-shell-extension` | `tilingshell-gnome-shell-extension` |

## Verification

1. Build: `cd /home/herpiko/src/tilingshell && dpkg-buildpackage -us -uc -b`
2. Inspect: `dpkg-deb -c tilingshell-gnome-shell-extension_17.3-1_all.deb` — verify files are in correct locations
3. Install: `sudo dpkg -i tilingshell-gnome-shell-extension_17.3-1_all.deb`
4. Check system files: `ls /usr/share/gnome-shell/extensions/tilingshell@ferrarodomenico.com/`
5. Check autostart deployed: `ls /etc/skel/.config/autostart/tilingshell-extension-update.desktop`
6. Log out/in, verify `~/.local/share/gnome-shell/extensions/tilingshell@ferrarodomenico.com/` is populated
7. Verify extension appears in GNOME Extensions app
