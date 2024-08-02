#!/bin/bash

# Load the TARGET_IP variable from the environment
[ -r /etc/profile.d/target.env ] && . /etc/profile.d/target.env

# Read commands from /etc/mdos.conf and store them in an array
cmds_arr=()
while IFS= read -r line || [ -n "$line" ]; do
  # Skip empty lines
  [ -z "$line" ] && continue
  
  # Add the command to the array
  cmds_arr+=("$line")
done < /etc/mdos.conf

# Function to split tmux window into 8 equally sized panes
split_window_into_panes() {
  tmux split-window -h
  tmux split-window -v -t 0
  tmux split-window -v -t 2
  tmux select-pane -t 0
  tmux split-window -h
  tmux select-pane -t 2
  tmux split-window -h
  tmux select-pane -t 4
  tmux split-window -h
  tmux select-pane -t 6
  tmux split-window -h
}

# Ensure tmux is running
if [ -n "$TMUX" ]; then
  total_cmds=${#cmds_arr[@]}
  cmds_per_window=8
  total_windows=$(( (total_cmds + cmds_per_window - 1) / cmds_per_window ))

  # Loop over each set of 8 commands
  for ((w=0; w<total_windows; w++)); do
    # For the first window, use the current window, otherwise create a new window
    if [ $w -gt 0 ]; then
      tmux new-window
    fi
    
    # Split the current tmux window into 8 equally sized panes
    split_window_into_panes

    # Execute commands in the panes
    for ((p=0; p<cmds_per_window; p++)); do
      cmd_idx=$((w * cmds_per_window + p))
      [ $cmd_idx -ge $total_cmds ] && break

      command="${cmds_arr[$cmd_idx]}"
      pane_idx=$((p))

      # Move to the appropriate pane and run the command
      tmux select-pane -t $pane_idx
      tmux send-keys "source /etc/profile.d/target.env && eval \"$command\"" C-m
    done
  done

  # Return to the first pane of the last window
  tmux select-pane -t 0
else
  echo "This script must be run inside a tmux session."
fi
