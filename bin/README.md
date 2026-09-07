# sgpt-warp-hotkey.sh

Makes `Fn+L` in Warp trigger [shell-gpt](https://github.com/TheR1D/shell_gpt)'s
inline command suggestion (Windows `Ctrl+L` muscle memory), since Warp can't
run shell-gpt's normal integration.

## Why this exists

shell-gpt normally works by binding a zsh `zle` widget to a key (see the
`_sgpt_zsh` function in `~/.zshrc`, bound to `Ctrl+L`). That works fine in
Terminal.app, iTerm2, and kitty.

Warp doesn't forward custom key bindings to the shell while you're editing
the prompt. It intercepts them at the app level first, regardless of what's
configured in Warp's own keyboard shortcut settings. Confirmed across
several candidates (`Ctrl+L`, `Ctrl+G`, `Ctrl+O`, a raw F13 escape
sequence), all swallowed, and re-confirmed in September 2026 with a control
test: `Ctrl+L` fires the widget in Terminal.app and does nothing in Warp.
This is a known, unfixed Warp limitation
([warpdotdev/Warp#3705](https://github.com/warpdotdev/Warp/issues/3705),
closed "not planned"), not a config mistake.

## How the workaround works

Instead of asking Warp to forward a key into zsh, the script drives Warp
through actions it *does* handle correctly, namely select, copy, and paste:

1. `Cmd+A` / `Cmd+C` to grab the current input line via the clipboard.
2. Replace the line with a placeholder while the request is in flight.
3. Pipe the captured text through `sgpt --shell --no-interaction`.
4. Select all again and paste the result in.

The clipboard is the transport, so the script saves its prior contents and
restores them at the end. Non-text clipboards (images) don't survive the
round trip.

## Wiring

`fn+L` is one Karabiner rule with two manipulators, split by bundle ID:

- `com.apple.Terminal` gets a plain remap to `Ctrl+L`, which fires the
  existing `_sgpt_zsh` widget. No script, no clipboard.
- `dev.warp.Warp-Stable` runs this script via `shell_command`.

Karabiner invokes it as `$HOME/bin/sgpt-warp-hotkey`, a symlink into this
repo, so the rule survives the repo being moved or renamed.

After editing the rule file, remove and re-add the rule in Karabiner's
Complex Modifications UI. Editing the file alone does not change the
running config. Editing this script needs no such step, since the rule
points at a path rather than embedding the contents.

## Gotchas

- Requires `sgpt` on `PATH` (installed via pipx at `~/.local/bin/sgpt`).
  The script prepends that directory itself, because Karabiner runs commands
  with a minimal environment.
- Keystrokes go through `osascript` and System Events, so
  `karabiner_console_user_server` needs Accessibility rights. If the script
  runs but nothing appears, that's the cause.
- Status strings are ASCII on purpose. An emoji placeholder arrives in Warp
  as mojibake, its UTF-8 bytes decoded as MacRoman. The failure sits
  somewhere in the encoding path between the script and Warp and did not
  reproduce from an interactive shell.
- If nothing is on the prompt line, the script restores the clipboard and
  exits quietly.
- Relies on `Cmd+A` selecting only the current input line, not the whole
  scrollback. True for Warp's prompt, but worth re-checking if this ever
  stops working after a Warp update.
- `sgpt` itself costs roughly 2.5s per call, most of it API round trip plus
  Python startup. That dominates the total latency; the script layer is a
  rounding error.
