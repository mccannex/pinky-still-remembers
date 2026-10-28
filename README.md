# pinky-still-remembers

Decades of Windows muscle memory don't switch off at a Mac keyboard. I
regularly move between Windows, macOS, and Linux, and the same keys should
do the same thing on all three.

This is a [Karabiner-Elements](https://karabiner-elements.pqrs.org/) config
that makes macOS follow Windows shortcuts. It uses `fn` as the Windows
`Ctrl` key and leaves `Cmd` alone, so every native macOS shortcut keeps
working.

## Layout

- `karabiner/fn-windows-keys.json` - the rule file, symlinked to
  `~/.config/karabiner/assets/complex_modifications/`.
- `bin/` - scripts invoked from a rule for anything too complex for a
  single keystroke (see `bin/README.md`).

## Install

```bash
git clone git@github.com:mccannex/pinky-still-remembers.git
cd pinky-still-remembers
brew install --cask karabiner-elements
mkdir -p ~/bin ~/.config/karabiner/assets/complex_modifications
ln -sfn "$PWD/karabiner/fn-windows-keys.json" \
        ~/.config/karabiner/assets/complex_modifications/fn-windows-keys.json
ln -sfn "$PWD/bin/sgpt-warp-hotkey.sh" ~/bin/sgpt-warp-hotkey
```

Then open Karabiner-Elements. Approve the driver extension and grant Input
Monitoring when macOS prompts. Go to Complex Modifications, click Add rule,
and enable each rule.

The `fn+l` rule needs shell-gpt as well. Skip this if you don't use it.

1. Install it with `pipx install shell-gpt`, then run `sgpt` once to set
   the API key.
2. Run `sgpt --install-integration`. This adds the `_sgpt_zsh` widget to
   `~/.zshrc` and binds it to `Ctrl+L`. Terminal needs it, and it lives
   outside this repo.
3. Grant Accessibility to `karabiner_console_user_server` in System
   Settings. The Warp script needs it to send keystrokes.

## Changing a rule

1. Edit `karabiner/fn-windows-keys.json`.
2. Validate it with `jq . karabiner/fn-windows-keys.json`. A malformed file
   makes its rules vanish from Add rule with no error.
3. In Complex Modifications, remove the old copy of the rule.
4. Click Add rule and enable the new copy.

Karabiner copies each rule into `~/.config/karabiner/karabiner.json` when
you add it. The file in this repo is a template, so editing it alone
changes nothing that is running. Scripts in `bin/` don't need these steps,
because the rules point at their paths.

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
- **Finder**: `Cmd+Left` and `Cmd+Right` go back and forward in history,
  mirroring Windows `Alt+Left` / `Alt+Right`.
- **System**: `Option+E` opens Finder at the Desktop, mirroring Windows
  `Win+E`. `Option+D` shows and hides the desktop, mirroring Windows
  `Win+D`.

## Known limitations

**Left Option+E and Left Option+D lose their characters.** Left Option+E
no longer starts an é, and Left Option+D no longer types ∂. Both rules bind
Left Option only, so Right Option+E and Right Option+D still type them.

**Option+D depends on the function-key setting.** It sends `fn+F11`,
because this Mac keeps media keys primary and macOS turns a bare F11 into
volume-down. If "Use F1, F2, etc. keys as standard function keys" is turned
on, the roles flip: `fn+F11` becomes volume-down and the rule breaks. In
that case, change the rule to send a bare `f11`. Karabiner's
`expose_desktop` key code was tried first and macOS 26 ignored it.

**fn+delete replaces Forward Delete.** Nothing else on the keyboard
produces it afterward.

**Finder back and forward cost Cmd+Left as line-start.** Inside Finder,
for example while renaming a file, Cmd+Left no longer jumps to line-start.
Option+Left still jumps a word there. Option+arrow would match Windows
Alt+arrow more closely, but the Navigation rule already emits Option+arrow,
and Karabiner doesn't re-process its own output. Delete was considered for
back and rejected. Karabiner matches on the frontmost app, with no
condition for text-field focus, so a bare Delete remap would also fire
while renaming a file.

**Warp doesn't forward custom key bindings to the shell.** It intercepts
almost any non-default key combination while the prompt is being edited,
before the keystroke reaches zsh. Confirmed on Ctrl+L, Ctrl+G, Ctrl+O, and
a raw F13 escape sequence, all swallowed, and re-confirmed on Ctrl+L in
September 2026. This is a known, unfixed Warp issue
([warpdotdev/Warp#3705](https://github.com/warpdotdev/Warp/issues/3705),
closed "not planned"). `bin/sgpt-warp-hotkey.sh` works around it.
