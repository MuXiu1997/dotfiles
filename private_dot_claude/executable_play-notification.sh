#!/bin/bash

# Claude Code notification sound script
# Plays a sound when a notification is received or an agent completes a task

# Use custom audio file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOUND_PATH="$SCRIPT_DIR/notification-sound.mp3"

# Fallback to system default sounds if custom file does not exist
if [ ! -f "$SOUND_PATH" ]; then
    SOUND_PATH="/System/Library/Sounds/Glass.aiff"
    if [ ! -f "$SOUND_PATH" ]; then
        SOUND_PATH="/System/Library/Sounds/Ping.aiff"
    fi
fi

# Play sound in background
afplay "$SOUND_PATH" 2>/dev/null &