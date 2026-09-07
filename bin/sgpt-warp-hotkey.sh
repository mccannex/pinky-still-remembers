#!/bin/zsh
# Fn+L workaround for shell-gpt in Warp.
#
# Warp intercepts custom key bindings at its prompt before they reach zsh's
# line editor, so shell-gpt's zle widget (bound to Ctrl+L, see ~/.zshrc) never
# runs there. Re-confirmed 2026-09-07: Ctrl+L does nothing at a Warp prompt
# while firing correctly in Terminal.app. See warpdotdev/Warp#3705, closed
# "not planned".
#
# This gets the same result a different way: select the current input line,
# copy it, run it through `sgpt --shell`, then put the result back, using
# only select/copy/paste, which Warp does forward.
#
# Invoked via Karabiner (fn+L, scoped to Warp by bundle ID). No dependency
# on skhd.
#
# Text goes in by clipboard paste rather than synthesized typing. Typing
# through System Events costs one keystroke event per character and mangles
# anything outside the current keyboard layout, emoji included. Paste is a
# single event and carries arbitrary Unicode intact.

export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"

# Status strings. Kept ASCII deliberately.
#
# An emoji here (⌛) arrives in Warp as mojibake: its UTF-8 bytes e2 8c 9b get
# decoded as MacRoman and render as three accented characters. The mangling
# happens somewhere in the encoding path between this script and Warp's input
# line, and Karabiner's execution environment differs enough from an
# interactive shell that it couldn't be reproduced or pinned down from one.
# Forcing LC_CTYPE, LC_ALL, and __CF_USER_TEXT_ENCODING all failed to give a
# consistent result, as did setting the clipboard through osascript instead
# of pbcopy.
#
# These strings are on screen for roughly the duration of one sgpt call, so
# ASCII costs nothing. To retry an emoji, edit THINKING and test in Warp.
THINKING="[ sgpt is thinking... ]"
NO_RESULT="[ sgpt returned no result ]"

# Send a Cmd+<key> pair in a single osascript process. Each spawn costs
# roughly 50-100ms, so batching the pair matters more than the delay between
# them does.
cmd_pair() {
    /usr/bin/osascript \
        -e 'on run argv' \
        -e 'tell application "System Events"' \
        -e '    keystroke (item 1 of argv) using command down' \
        -e '    delay 0.08' \
        -e '    keystroke (item 2 of argv) using command down' \
        -e 'end tell' \
        -e 'end run' \
        "$1" "$2"
}

# Replace the current input line with $1.
replace_line() {
    printf '%s' "$1" | pbcopy
    cmd_pair a v
}

# The clipboard is the transport here, so hold the user's contents and put
# them back at the end. Non-text clipboards (images) don't survive this.
saved_clip="$(pbpaste)"
restore_clip() { printf '%s' "$saved_clip" | pbcopy; }

# Grab the current input line.
cmd_pair a c
prompt="$(pbpaste)"

if [[ -z "$prompt" ]]; then
    restore_clip
    exit 0
fi

replace_line "$THINKING"

result="$(sgpt --shell --no-interaction <<< "$prompt" 2>/dev/null)"
[[ -z "$result" ]] && result="$NO_RESULT"

replace_line "$result"
restore_clip
