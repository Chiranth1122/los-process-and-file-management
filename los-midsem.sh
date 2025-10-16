#!/bin/bash

# Function to show the current process tree with PIDs
show_pstree() {
  echo "Current process tree (with PIDs):"
  pstree -p
  echo
}

# Function to schedule this script using crontab or at
schedule_script() {
  echo "Schedule this script:"
  echo "1) Schedule recurring job with crontab"
  echo "2) Schedule one-time job with at"
  echo "3) Cancel scheduling"
  read -p "Choose option [1-3]: " sched_choice

  case $sched_choice in
    1)
      # crontab scheduling
      echo "Enter minute (0-59):"
      read minute
      echo "Enter hour (0-23):"
      read hour
      echo "Enter day of month (1-31 or *):"
      read dom
      echo "Enter month (1-12 or *):"
      read month
      echo "Enter day of week (0-7 or *):"
      read dow

      # Validate and create cron job line
      cron_line="$minute $hour $dom $month $dow $(realpath "$0")"
      (crontab -l 2>/dev/null; echo "$cron_line") | crontab -
      echo "Cron job added: $cron_line"
      ;;
    2)
      # at scheduling
      echo "Enter time for one-time job (e.g., 15:30, now + 1 minute, 10:00 AM 2025-10-20):"
      read at_time
      echo "$(realpath "$0")" | at "$at_time"
      echo "One-time job scheduled at $at_time"
      ;;
    3)
      echo "Cancelled scheduling."
      ;;
    *)
      echo "Invalid choice."
      ;;
  esac
}

# Main menu loop
while true; do
  echo "--------------------------------------"
  echo "PSTree Process Viewer & File Manager"
  echo "--------------------------------------"
  echo "1. Show current process tree"
  echo "2. Kill a process by PID"
  echo "3. Create a link (soft or hard)"
  echo "4. Add content to a file"
  echo "5. Search content in a file"
  echo "6. Schedule this script (cron or at)"
  echo "7. Exit"
  echo -n "Enter your choice [1-7]: "
  read choice

  case $choice in
    1)
      show_pstree
      ;;
    2)
      read -p "Enter PID of process to kill: " pid
      if kill -0 "$pid" 2>/dev/null; then
        kill "$pid" && echo "Process $pid killed."
      else
        echo "Invalid or no such process PID: $pid"
      fi
      ;;
    3)
      read -p "Link type (soft/hard): " link_type
      read -p "Target file: " target
      read -p "Link name: " linkname
      if [ ! -e "$target" ]; then
        echo "Target file does not exist."
      else
        if [[ "$link_type" == "soft" ]]; then
          ln -s "$target" "$linkname" && echo "Soft link created."
        elif [[ "$link_type" == "hard" ]]; then
          ln "$target" "$linkname" && echo "Hard link created."
        else
          echo "Invalid link type entered."
        fi
      fi
      ;;
    4)
      read -p "Filename to add content: " fname
      read -p "Content to add: " content
      echo "$content" >> "$fname" && echo "Content added to $fname."
      ;;
    5)
      read -p "Filename to search: " fname
      if [ ! -f "$fname" ]; then
        echo "File not found."
      else
        read -p "Keyword to search: " keyword
        echo "Search results:"
        grep --color=auto "$keyword" "$fname" || echo "No matches found."
      fi
      ;;
    6)
      schedule_script
      ;;
    7)
      echo "Exiting PSTree Process Viewer & File Manager."
      break
      ;;
    *)
      echo "Invalid choice, please try again."
      ;;
  esac
  echo
done
