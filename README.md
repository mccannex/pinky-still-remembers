# pinky-still-remembers

Fifteen years of Ctrl+C, Ctrl+V, Alt+Tab live in muscle memory. macOS
remaps all of them. This repo remaps them back.

## Why

Muscle memory only pays off when the keys stay put. macOS moves them: Cmd
where Windows uses Ctrl, different nav-key behavior, apps that reinterpret
keystrokes mid-edit. Every mismatch is a small tax on a keystroke you'll
make thousands of times. This config, built on
[skhd](https://github.com/koekeishiya/skhd), maps `fn` to `Ctrl` across the
shortcuts that matter, with every exception documented below.

## Layout

- `.skhdrc` - the skhd config, symlinked to `~/.skhdrc`.
- `bin/` - scripts invoked from `.skhdrc` for anything too complex for a
  single keystroke (see `bin/README.md`).

## What's in `.skhdrc`

- **system**: `fn+q` quits the app, `Option+E` opens Folders at home.
- **editing**: `fn+a/v/x/z/y/s/f/w` for `Ctrl+A/V/X/Z/Y/S/F/W`. `fn+c` is
  app aware: real `Ctrl+C` (SIGINT) in shells, `Cmd+C` (copy) everywhere
  else.
- **windows-style navigation**: `fn+delete` for word-backward-delete.
  Arrow keys are deliberately excluded, see below.
- **tab cycling**: `fn+tab` / `fn+shift+tab` cycle tabs forward/back in
  Chrome, Brave, and Warp.
- **browser** (Chrome/Brave): `fn+t` new tab, `fn+r` reload, `fn+shift+t`
  reopen closed tab. `Cmd+D` focuses the address bar instead of
  bookmarking.
- **shell-gpt**: `fn+l` triggers an AI command suggestion hotkey. Warp
  needs a workaround, see `bin/README.md`.

## Known limitations

**skhd matches process names, not display names.** Warp's frontmost
process name is `"stable"`, its release channel, not `"Warp"`. Rules
meant for Warp need to match both or they silently never fire.

**Warp doesn't forward custom key bindings to the shell.** It intercepts
almost any non-default key combination while the prompt is being edited,
before the keystroke reaches zsh. Confirmed on Ctrl+L, Ctrl+G, Ctrl+O, and
a raw F13 escape sequence, all swallowed. This is a known, unfixed Warp
issue ([warpdotdev/Warp#3705](https://github.com/warpdotdev/Warp/issues/3705),
closed "not planned"). `bin/sgpt-warp-hotkey.sh` works around it with
select, copy, type in place of a forwarded keypress.

**Arrow and nav-cluster keys always report the Fn flag.** Apple hardware
sets the Fn bit on arrow keys, Home/End, Forward-Delete, and the F-row
unconditionally, whether or not the physical Fn key is held. skhd can't
tell "arrow key alone" from "Fn+arrow key" for this set of keys.
`fn+left/right/up/down` bindings were removed for this reason. `fn+delete`
is unaffected since plain Backspace isn't part of that key class.

## Reloading after edits

```bash
launchctl kickstart -k gui/$(id -u)/com.koekeishiya.skhd
```

`skhd -r` works too if the daemon is already healthy.
