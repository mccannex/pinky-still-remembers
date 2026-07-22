#!/bin/zsh
# Fn+L workaround for shell-gpt in Warp.
#
# Warp intercepts custom key bindings at its prompt before they reach zsh's
# line editor (confirmed via testing; see warpdotdev/Warp#3705, closed "not
# planned"), so shell-gpt's normal zle widget (bound to Ctrl+L, see ~/.zshrc)
# never fires there. This script gets the same result a different way: select
# the current input line, copy it, run it through `sgpt --shell`, and type
# the result back in - using only select/copy/type, which Warp does forward.
#
# Invoked via skhd (see .skhdrc, fn - l), scoped to Warp only.

export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"

skhd -k "cmd - a"
sleep 0.05
skhd -k "cmd - c"
sleep 0.1

prompt="$(pbpaste)"
[[ -z "$prompt" ]] && exit 0

skhd -t "⌛ sgpt is thinking..."

result="$(sgpt --shell --no-interaction <<< "$prompt" 2>/dev/null)"
[[ -z "$result" ]] && result="⚠️ sgpt returned no result"

skhd -k "cmd - a"
sleep 0.05
skhd -t "$result"
