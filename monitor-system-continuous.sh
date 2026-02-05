#!/bin/bash
# Continuous system monitoring
echo "Starting continuous monitoring..."
while true; do
    echo "=== System Check $(date '+%H:%M:%S') ==="
    echo "Tools: $(ls /c/scripts/tools/*.ps1 | wc -l)"
    echo "Uptime: $(uptime)"
    sleep 300  # Check every 5 minutes
done
