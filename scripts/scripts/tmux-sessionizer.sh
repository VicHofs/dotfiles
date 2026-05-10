#!/usr/bin/env bash

switch_to() {
    if [[ -z $TMUX ]]; then
        tmux attach-session -t "$1"
    else
        tmux switch-client -t "$1"
    fi
}

has_session() {
    tmux list-sessions | grep -q "^$1:"
}

hydrate() {
    if [ -f "$2/.tmux-sessionizer" ]; then
        tmux send-keys -t "$1" "source \"$2/.tmux-sessionizer\"" C-m
    elif [ -f "$HOME/.tmux-sessionizer" ]; then
        tmux send-keys -t "$1" "source \"$HOME/.tmux-sessionizer\"" C-m
    fi
}

session_roots() {
    if [[ -n ${TMUX_SESSIONIZER_DIRS:-} ]]; then
        tr ':' '\n' <<< "$TMUX_SESSIONIZER_DIRS"
    else
        printf '%s\n' "${DOTFILES_DIR:-$HOME/dotfiles}" "$HOME/Desktop" "$HOME"
    fi
}

# Use CLI arg if provided, otherwise fzf from configured roots.
if [[ $# -eq 1 ]]; then
    selected=$1
else
    mapfile -t roots < <(session_roots)
    selected=$(fd -H . "${roots[@]}" -t d -d 1 | fzf)
fi

# Abort if nothing selected
if [[ -z $selected ]]; then
    exit 0
fi

# Normalize session name (basename with dots replaced)
selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# Create session if tmux not running
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -ds "$selected_name" -c "$selected"
    hydrate "$selected_name" "$selected"
fi

# Create session if it doesn't exist
if ! has_session "$selected_name"; then
    tmux new-session -ds "$selected_name" -c "$selected"
    hydrate "$selected_name" "$selected"
fi

# Switch or attach
switch_to "$selected_name"
