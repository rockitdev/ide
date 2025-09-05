# Development layout - IDE-like setup
# Main editor (70%) | Terminal (30% top) | Server logs (30% bottom)

split-window -h -p 30
split-window -v -p 50
select-pane -t 1
send-keys 'nvim' C-m
select-pane -t 2
send-keys 'clear' C-m
select-pane -t 3
display-message "Development layout activated"