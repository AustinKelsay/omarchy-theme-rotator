# Theme Rotation

Theme Rotation changes the active Omarchy theme according to a user-owned
policy while keeping manual control available from the shell widget and CLI.

## Language

**Rotation**:
A successful change from the active theme to a different eligible theme.
_Avoid_: Switch, cycle, update

**Schedule**:
The elapsed-time policy that determines when an automatic rotation is due.
_Avoid_: Timer, interval loop, daemon

**Eligible Theme**:
An available theme that is not the active theme and is not excluded by policy.
_Avoid_: Candidate, allowed theme

**Rotation Mode**:
The policy for choosing an eligible theme: random or sequential.
_Avoid_: Strategy, order

**Theme Source**:
The Omarchy collection from which available themes are read: all or extras.
_Avoid_: Theme list, scope

**Paused**:
A user-controlled state that suppresses scheduled rotations while preserving
manual rotations.
_Avoid_: Disabled, stopped

