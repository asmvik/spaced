## spaced

Grid-based space management for macOS 26.0+, using native spaces.

<img align="center" width="80%" src="assets/screenshot.png" alt="Screenshot">

### Features

 - Visualize space thumbnails in grid overview by holding down `<mod>` for 1 second.
 - Switch between spaces by left-clicking a thumbnail while overview mode is active.
 - Switch between spaces in grid, skipping animation, by tapping `<mod> + <arrow-key>`.
 - Shortcuts are not affected by Secure Input (Secure Keyboard Entry) limitations.

### Permissions

 - Requires access to CGEventPost API to synthesize native space switch events.
 - Requires Screen Capture access to display space thumbnails in overview mode.  
   Desktop Wallpaper will be shown if Screen Capture access is not granted. 
