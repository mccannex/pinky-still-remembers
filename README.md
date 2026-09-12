# pinky-still-remembers

Fifteen years of Ctrl+C, Ctrl+V, Alt+Tab live in muscle memory. macOS
remaps all of them. This repo remaps them back.

## Why

Muscle memory only pays off when the keys stay put. macOS moves them: Cmd
where Windows uses Ctrl, different nav-key behavior, apps that reinterpret
keystrokes mid-edit. Every mismatch is a small tax on a keystroke you'll
make thousands of times. This config, built on
[Karabiner-Elements](https://karabiner-elements.pqrs.org/), uses the
otherwise-idle `fn` key as the Windows `Ctrl` stand-in, leaving `Cmd` where
macOS put it.

That approach is deliberate and uncommon. Most "PC style" configs swap
`Ctrl` and `Cmd` wholesale, which breaks `Ctrl+C` as SIGINT in a shell.
Mapping `fn` instead leaves every native macOS shortcut intact.

## Layout

- `karabiner/fn-windows-keys.json` - the rule file, symlinked to
  `~/.config/karabiner/assets/complex_modifications/`.
- `bin/` - scripts invoked from a rule for anything too complex for a
  single keystroke (see `bin/README.md`).

## Install

```bash
brew install --cask karabiner-elements
ln -sfn "$PWD/karabiner/fn-windows-keys.json" \
        ~/.config/karabiner/assets/complex_modifications/fn-windows-keys.json
ln -sfn "$PWD/bin/sgpt-warp-hotkey.sh" ~/bin/sgpt-warp-hotkey
```

Then open Karabiner-Elements, go to Complex Modifications, click Add rule,
and enable each rule. Approve the driver extension and grant Input
Monitoring when macOS prompts.

## Rules

- **Editing**: `fn+a/v/x/z/y` for select all, paste, cut, undo, redo.
- **File and window**: `fn+s/f/w/q` for save, find, close, quit.
- **Delete**: `fn+delete` deletes the previous word.
- **Navigation**: `fn+left/right` jump by word. Shift passes through, so
  `fn+shift+left` selects by word.
- **Copy / interrupt**: `fn+c` is app aware. Real `Ctrl+C` (SIGINT) in
  Terminal and Warp, `Cmd+C` (copy) everywhere else.
- **Browser**: `fn+tab` and `fn+shift+tab` cycle tabs in Brave and Warp.
  `fn+t`, `fn+r`, `fn+shift+t` are new tab, reload, and reopen closed tab
  in Brave. `Cmd+D` focuses the address bar, replacing add-bookmark.
- **shell-gpt**: `fn+l` requests a command suggestion. Terminal gets a
  plain remap to `Ctrl+L`; Warp needs a script (see `bin/README.md`).
- **Folders**: `Cmd+Left` and `Cmd+Right` go back and forward in history,
  mirroring Windows `Alt+Left` / `Alt+Right`. Cmd rather than Option,
  because Option+arrow is what the Navigation rule already emits and
  Karabiner doesn't re-process its own output.
- **System**: `Option+E` opens Folders at home, mirroring Windows `Win+E`.
  `Option+D` shows and hides the desktop, mirroring Windows `Win+D`.

## Known limitations

**Editing a rule file does not change what is running.** Karabiner copies a
rule into `~/.config/karabiner/karabiner.json` when you click Add rule. The
file in this repo is a template. After changing a rule, remove it and re-add
it in the UI, or the old copy keeps running.

**Option+E is the acute accent dead key.** Binding it to Folders means
`Option+E, e` no longer types é. `Option+D` costs the ∂ character the same
way.

**Show Desktop needs fn+F11, not F11.** This Mac keeps media keys primary,
so macOS turns a bare F11 into volume-down. The `Option+D` rule sends
`fn+F11` for that reason. Karabiner's `expose_desktop` key code was tried
first and macOS 26 ignored it.

**fn+delete replaces Forward Delete.** Nothing else on the keyboard
produces it afterward.

**Cmd+Left is no longer line-start inside Folders.** Option+Left still
does word-left there, which is the more useful of the two in a filename.
Delete was considered for back instead and rejected: Karabiner matches on
the frontmost application and has no condition for whether a text field has
focus, so a bare Delete remap would fire while renaming a file.

**Warp doesn't forward custom key bindings to the shell.** It intercepts
almost any non-default key combination while the prompt is being edited,
before the keystroke reaches zsh. Confirmed on Ctrl+L, Ctrl+G, Ctrl+O, and
a raw F13 escape sequence, all swallowed, and re-confirmed on Ctrl+L in
September 2026. This is a known, unfixed Warp issue
([warpdotdev/Warp#3705](https://github.com/warpdotdev/Warp/issues/3705),
closed "not planned"). `bin/sgpt-warp-hotkey.sh` works around it.

## History

This started on [skhd](https://github.com/koekeishiya/skhd) and moved to
Karabiner-Elements. skhd reads keys through a CGEvent tap, which sees the
Fn flag that Apple hardware sets unconditionally on arrow keys, Home/End,
Forward-Delete, and the F-row. It can't tell a plain arrow press from
`fn+arrow`, so word-jump bindings on the arrow keys fired on every arrow
press and had to be abandoned. Karabiner reads the device below that layer
and distinguishes the two, which is the reason for the move.

Karabiner also matches applications by bundle identifier rather than
process name. Under skhd, rules meant for Warp had to match `"stable"`, its
release channel, because that is the process name; `"Warp"` silently never
fired. `dev.warp.Warp-Stable` removes the guesswork.

The skhd config is preserved in git history if it is ever needed.
