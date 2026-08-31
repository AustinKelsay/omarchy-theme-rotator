# Contributing

## Workflow

1. Create a focused branch.
2. Describe user-visible behavior in `docs/SPEC.md` when it changes.
3. Add one failing behavioral test at a public seam.
4. Implement only enough to make that slice pass.
5. Run `make check`.
6. Open a pull request that explains behavior and verification.

Tests should survive internal refactors. Do not test sourced functions or QML
implementation details when the behavior is observable through the CLI,
installer, or the `Status.js` widget contract module.

## Requirements

- Bash 5+
- `jq`
- `flock`
- ShellCheck for local linting (CI always runs it)
- Omarchy for live plugin validation and UI testing

## Live check

```bash
omarchy plugin validate .
make check
```

Changes under an installed Omarchy plugin directory hot-reload. Check the
widget tooltip, both mouse actions, and `omarchy-shell` logs before release.
