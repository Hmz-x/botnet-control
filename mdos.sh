#!/bin/bash

# Load the TARGET variable from the environment
[ -r /etc/profile.d/target.env ] && . /etc/profile.d/target.env

# Read commands from /etc/mdos.conf and store them in an array
cmds_arr=()
while IFS= read -r line || [ -n "$line" ]; do
  # Skip empty lines
  [ -z "$line" ] && continue
  
  # Add the command to the array
  cmds_arr+=("$line")
done < /etc/mdos.conf

# Ensure tmux is running
if [ -n "$TMUX" ]; then
  # Number of commands
  num_cmds=${#cmds_arr[@]}

  # Calculate the number of splits needed
  num_splits=$((num_cmds - 1))

  # Perform the necessary splits
  for i in $(seq 1 $num_splits); do
    if [ $((i % 2)) -eq 1 ]; then
      tmux split-window -h
    else
      tmux select-pane -L
      tmux split-window -v
      tmux select-pane -R
    fi
  done

  # Execute commands in each pane
  for i in $(seq 0 $((num_cmds - 1))); do
    command="${cmds_arr[$i]}"

    # Move to the appropriate pane
    tmux select-pane -t $i

    # Send command to the pane: source target.env and then eval the command
    tmux send-keys "source /etc/profile.d/target.env && eval \"$command\"" C-m
  done

  # Return to the first pane
  tmux select-pane -t 0
else
  echo "This script must be run inside a tmux session."
fi
