# Vampir Web build

This branch is the browser-only build target for the Godot project.

- Renderer: Godot GL Compatibility (WebGL 2).
- Export target: Web (single-threaded WASM for broad browser compatibility).
- Deployment: GitHub Actions publishes `godot/build/web` to GitHub Pages.
- No Windows or Android export preset is included on this branch.

After deployment, open the GitHub Pages URL on desktop or mobile Safari/Chrome. The game still needs browser-compatible input; desktop keyboard/mouse support is inherited from the game. Touch-specific controls must be implemented in-game if the current controls do not already support touch.
