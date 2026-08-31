# Security policy

Report vulnerabilities privately through GitHub's security advisory interface
for this repository. Do not open a public issue for an unpatched vulnerability.

Theme Rotator executes `omarchy`, reads user-owned configuration, and writes
only beneath the user's XDG config, state, runtime, and bin directories. It does
not require root access or network access at runtime.

`theme-rotator.conf` is sourced as Bash to support array configuration. Treat
it as executable user code and never install a configuration file from an
untrusted source.

