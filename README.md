# Omarchy Theme Rotator

A configurable automatic theme rotator for [Omarchy](https://omarchy.org/),
with a native Omarchy Shell bar widget.

The widget shows the current rotation state and provides mouse controls:

- Left click: switch to the next theme
- Right click: pause or resume rotation
- Middle click: restart the service and reload configuration

## Install

Requirements: Omarchy, `jq`, `flock`, and an Omarchy Shell version with user
plugin support.

```bash
git clone https://github.com/AustinKelsay/omarchy-theme-rotator.git
cd omarchy-theme-rotator
./install.sh
```

The installer copies the widget and helper into your user directories,
installs and enables the systemd user service, and creates a default config if
one does not already exist.

Add `plebdev.theme-rotator` to your Omarchy bar through the bar settings, or
with the supported `omarchy bar` commands for your Omarchy version.

## Configure

Edit `~/.config/omarchy/theme-rotator.conf`. Changes are read automatically on
the next daemon cycle; middle-click the widget to force an immediate reload.

```bash
INTERVAL_SECONDS=300
MODE="random"
THEME_SOURCE="all"
EXCLUDE_THEMES=("mapquest" "red-pill")
NOTIFY=true
```

- `INTERVAL_SECONDS`: rotation interval, clamped to a minimum of 30 seconds
- `MODE`: `random` or `sequential`
- `THEME_SOURCE`: `all` or `extras`
- `EXCLUDE_THEMES`: lowercase, hyphenated theme slugs to skip
- `NOTIFY`: show a desktop notification after changing themes

## CLI

```bash
omarchy-theme-rotator status
omarchy-theme-rotator next
omarchy-theme-rotator pause
omarchy-theme-rotator resume
omarchy-theme-rotator toggle
```

## License

MIT

