#!/bin/bash
tmux list-sessions |
	sed -E 's/:.*$//' |
	grep -v "^$(tmux display-message -p '#S')\$" |
	fzf --reverse --ghost="Session name" --header="Available Sessions:" --height=10 --border --border=rounded --border-label=" Switch Tmux Session " --color=label:italic:black |
	xargs tmux switch-client -t
