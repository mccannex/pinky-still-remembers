# sgpt-warp-hotkey.sh

Makes `Fn+L` in Warp trigger [shell-gpt](https://github.com/TheR1D/shell_gpt)'s
inline command suggestion (Windows `Ctrl+L` muscle memory), since Warp can't
run shell-gpt's normal integration.

## Why this exists

shell-gpt normally works by binding a zsh `zle` widget to a key (see the
`_sgpt_zsh` function in `~/.zshrc`, bound to `Ctrl+L`). That works fine in
Terminal.app, iTerm2, and kitty.

Warp doesn't forward custom key bindings to the shell while you're editing
the prompt - it intercepts them at the app level first, regardless of what's
configured in Warp's own keyboard shortcut settings. Confirmed across several
candidates (`Ctrl+L`, `Ctrl+G`, `Ctrl+O`, a raw F13 escape sequence) - all
swallowed. This is a known, unfixed Warp limitation
([warpdotdev/Warp#3705](https://github.com/warpdotdev/Warp/issues/3705),
closed "not planned"), not a config mistake.

## How the workaround works

Instead of asking Warp to forward a key into zsh, the script drives Warp
through actions it *does* handle correctly - select, copy, type:

1. `Cmd+A` / `Cmd+C` to grab the current input line via the clipboard.
2. Type a `⌛` placeholder in its place (via `skhd -t`) as a waiting indicator.
3. Pipe the captured text through `sgpt --shell --no-interaction`.
4. Select-all again and type the result back in.

## Wiring

- `.skhdrc`: `fn - l` runs this script, scoped to Warp only.
- Warp's actual frontmost process name is `"stable"` (its release channel),
  not `"Warp"` - the skhd rule matches both.
- After editing `.skhdrc`, reload with:
  `launchctl kickstart -k gui/$(id -u)/com.koekeishiya.skhd`

## Gotchas

- Requires `sgpt` on `PATH` (installed via pipx at `~/.local/bin/sgpt`).
- If nothing is selected/typed on the prompt line, the script exits quietly.
- Relies on `Cmd+A` selecting only the current input line, not the whole
  scrollback - true for Warp's prompt, but worth re-checking if this ever
  stops working after a Warp update.
