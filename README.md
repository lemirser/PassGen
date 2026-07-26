# PassGen

A lightweight macOS menu bar utility for generating strong, secure passwords, inspired by [Proton Pass's password generator](https://proton.me/pass/password-generator).

PassGen lives quietly in your menu bar, no Dock icon, no clutter, and gives you a fast way to generate, inspect, and copy secure passwords without opening a browser or another app.

## Features

- **Menu bar only** — runs as a background utility, similar to Time Machine, with no Dock icon or app switcher presence
- **Adjustable length** — type any password length between 8 and 64 characters directly, with automatic validation and clamping
- **Character type toggles** — independently enable or disable Capital Letters, Numbers, and Symbols (at least one type is always required)
- **Guaranteed character variety** — when multiple types are enabled, the generator guarantees at least one character of each active type appears in the result
- **Live regeneration** — the password automatically regenerates whenever you change the length or toggle a character type
- **Color-coded characters** — capital letters, numbers, and symbols are visually color-coded within the displayed password for quick scanning
- **Entropy-based strength scoring** — password strength is calculated using real entropy (length × log2(pool size)), not a simplified heuristic
- **Visual strength bar** — a color-coded progress bar (red → yellow → light green → green) reflects password strength at a glance
- **Secure clipboard copy** — copying a password automatically clears the clipboard after 90 seconds, but only if the clipboard still contains that exact password, so it won't wipe out anything else you've copied since
- **Word-wrapped display** — long passwords wrap cleanly across multiple lines for readability, while the copied value always remains a single unbroken string

## Requirements

- macOS Ventura (13.0) or later
- Xcode 15 or later (to build from source)

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/lemirser/PassGen.git
   ```
2. Open `PassGen.xcodeproj` in Xcode
3. Select your Mac as the run destination
4. Build and run (⌘R)

Once running, look for the PassGen icon in your menu bar to open the password generator panel.

## How It Works

- **Password generation**: builds a character pool from the currently enabled toggles, guarantees at least one character from each active type, fills the remaining length with random characters from the combined pool, then shuffles the result to avoid predictable ordering.
- **Strength scoring**: entropy is calculated once per password change (not on every screen redraw) and cached, then reused by the strength label, color, and progress bar to avoid redundant calculation.
- **Clipboard security**: copying starts a 90-second timer that clears the clipboard, but only if it still holds the exact password that was copied, protecting against accidentally erasing unrelated clipboard content.

## Roadmap

- [ ] Custom app icon
- [ ] App Store preparation (developer account, screenshots, listing)
- [ ] Additional polish and accessibility pass

## License

This project is licensed under the MIT License, see the [LICENSE](LICENSE) file for details.
