# Omarchy Theme Rotator

Automatic theme rotation that feels native to [Omarchy](https://omarchy.org/).
Theme Rotator runs inside Omarchy Shell, remembers its schedule, and gives you
one-click control from the bar.

## What you get

- Random or sequential theme rotation
- Configurable rotation interval and theme exclusions
- All themes or extras-only sources
- Persistent pause/resume state
- Native bar status and controls
- No root access and no system daemon
- A scriptable JSON CLI

## Install

The native Omarchy path installs and enables the entire plugin:

```bash
omarchy plugin add https://github.com/AustinKelsay/omarchy-theme-rotator.git --enable
```

To also install the short `omarchy-theme-rotator` command on your `PATH`, clone
the repository and run its idempotent installer:

```bash
git clone https://github.com/AustinKelsay/omarchy-theme-rotator.git
cd omarchy-theme-rotator
./install.sh
```

The installer detects and disables the pre-2.0 systemd user service, preserves
your existing configuration, and can be safely rerun for upgrades.

## Use the widget

- Left click rotates immediately.
- Right click pauses or resumes scheduled rotation.
- Hover shows the active theme, time remaining, mode, source, and interval.

If Omarchy did not place the widget automatically:

```bash
omarchy bar put plebdev.theme-rotator --section right
```

## Configure

Copy the example when you install only through Omarchy's plugin manager:

```bash
cp ~/.config/omarchy/plugins/plebdev.theme-rotator/theme-rotator.conf.example \
  ~/.config/omarchy/theme-rotator.conf
```

Then edit `~/.config/omarchy/theme-rotator.conf`:

```bash
INTERVAL_SECONDS=300
MODE="random"
THEME_SOURCE="all"
EXCLUDE_THEMES=("mapquest" "red-pill")
NOTIFY=true
```

Configuration is loaded on every command and scheduled check. Invalid values
fall back to safe defaults with a warning. Because the file is sourced as
user-owned Bash to support arrays, do not copy configuration from untrusted
sources.

## CLI

When installed through Omarchy alone, use the CLI at:

```bash
~/.config/omarchy/plugins/plebdev.theme-rotator/bin/omarchy-theme-rotator status
```

The optional installer puts the same command at `~/.local/bin`.

| Command | Behavior |
| --- | --- |
| `status` | Print the stable widget contract as JSON |
| `tick` | Rotate only if the schedule is due |
| `next` | Rotate now, including while paused |
| `pause` | Suppress scheduled rotations |
| `resume` | Resume with a fresh interval |
| `toggle` | Toggle paused state |
| `config` | Print effective validated configuration as JSON |
| `help` | Show CLI help |

## Uninstall

Native installation:

```bash
omarchy plugin remove plebdev.theme-rotator
```

Installer-based installation from a separate clone:

```bash
./install.sh uninstall
```

Both approaches preserve configuration and state intentionally.

## Develop

```bash
make check
```

The suite tests behavior through the CLI, installer lifecycle, and QML/JSON
contract seams. See [CONTRIBUTING.md](CONTRIBUTING.md),
[docs/DESIGN.md](docs/DESIGN.md), and [CONTEXT.md](CONTEXT.md).

## License

[MIT](LICENSE)

