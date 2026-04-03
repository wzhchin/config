#!/bin/bash
session=$(tmux display-message -p '#S')
tmux list-windows |
	grep -v "^$(tmux display-message -p '#I'):" |
	fzf --reverse --border --border-label=" Switch Tmux Window " --color=label:italic:black \
		--delimiter=':' \
		--preview="tmux capture-pane -p -t '${session}:{1}'" \
		--preview-window=right:60% |
	awk -F: '{print $1}' |
	xargs tmux select-window -t
