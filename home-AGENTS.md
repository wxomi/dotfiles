# Workspace Guidelines

- **macOS Clipboard (`pbcopy`)**:
  - Whenever the user asks to copy something (e.g., "copy this", "pbcopy that", "add to clipboard"), run `pbcopy` directly via bash command to place the content on their system clipboard.
  - When generating output intended for external pasting, offer or pipe it directly into `pbcopy` so the user doesn't have to highlight and copy terminal text manually.
