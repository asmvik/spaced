<h2 align="center">
    spaced
</h2>
<p align="center">
  <b>Grid-based space management for macOS.</b>
</p>
<p align="center">
    <img width="75%" src="assets/screenshot.png" alt="Screenshot">
</p>
<p align="center">
  <a href="https://github.com/asmvik/spaced/blob/main/CHANGELOG.md">
    <img src="https://img.shields.io/badge/view-changelog-green.svg" alt="Changelog Badge">
  </a>
  <a href="https://github.com/asmvik/spaced/releases">
    <img src="https://img.shields.io/github/commits-since/asmvik/spaced/latest.svg?color=green" alt="Version Badge">
  </a>
</p>

### System Requirements

 - **Architecture**: Apple Silicon
 - **Operating System**: macOS 26 Tahoe

### Features

 - Visualize space thumbnails in grid overview by holding down `cmd` for 1 second.
 - Switch between spaces by left-clicking a thumbnail while overview mode is active.
 - Switch between spaces in grid, skipping animation, by tapping `cmd + <arrow-key>`.
 - Shortcuts are not affected by Secure Input (Secure Keyboard Entry) limitations.

Quit by holding `cmd` until the overview is visible, then press `q`.

### Permissions

 - Requires access to CGEventPost API to synthesize native space switch events. Effectively, this is the same as granting access to the Accessibility API.
 - Requires Screen Capture access to display space thumbnails in overview mode. Desktop Wallpaper will be shown if Screen Capture access is not granted.

### Installation

 - Navigate to the [latest release](https://github.com/asmvik/spaced/releases/latest) and download `spaced.dmg`
 - Double-click the downloaded `.dmg` file. Drag and drop `spaced` into `Applications`.
 - Eject the `.dmg` in Finder sidebar or using the Desktop icon and delete it.

If you see a security warning that the app cannot be opened or is from an unidentified developer:
 - Open `System Settings`. Choose `Privacy & Security`.
 - Scroll down to the message: `"spaced" was blocked to protect your Mac.` and click `Open Anyway`.

### Start on login

Open `System Settings`. Choose `General` and select `Login Items & Extensions`. In the top section labeled `Open at Login`, click the `+` symbol and select `spaced` in your `Applications` folder.
