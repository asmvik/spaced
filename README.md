## spaced

Grid-based space management for macOS 26.0+, using native spaces.

### Features

 - Visualize space thumbnails in grid overview using `<mod> + <overview-key>`.
 - Switch between spaces in grid, skipping animation, using `<mod> + <arrow-key>`.
 - Shortcuts are not affected by Secure Input (Secure Keyboard Entry) limitations.

### Permissions

 - Requires Screen Capture access to display space thumbnails in overview mode.
 - Requires access to CGEventPost API to synthesize native space switch events.
