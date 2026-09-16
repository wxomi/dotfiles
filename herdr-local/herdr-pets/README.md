# Herdr Pets (vscode-pets style)

Pixel cat that walks on a floor panel — like [vscode-pets](https://marketplace.visualstudio.com/items?itemName=tonybaloney.vscode-pets).

## Open

| Shortcut | What |
|----------|------|
| `Ctrl+a` `Alt+k` | Pets **panel** (explorer-style popup) |
| `Ctrl+a` `Alt+p` | Pets **bottom strip** |

Or:
```bash
herdr plugin action invoke wxomi.pets.open-panel
herdr plugin action invoke wxomi.pets.open-dock
```

Press `q` in the pets pane to quit.

## Notes

- Renders PNG sprites as truecolor half-blocks (Herdr does not reliably pass Kitty graphics).
- Agents sidebar stays text-only — it cannot host a pixel pet.
- Optional forest theme: `HERDR_PETS_THEME=forest` (auto-enables on large panels).
