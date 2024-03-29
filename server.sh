#!/bin/bash

# This is the main server application!
# Can be configured to:
#   1. Create new new wallpapers
#   2. Updated wallpaper in repository
#   3. Set desktop wallpaper
# Or any subset of those three.

# Ensure a base directory was provided.
if [ -z "$1" ]
then
    echo "sync_wallpaper.sh \$1 must be the wallpaper repo"
    exit 1
fi
REPO_DIR=$(realpath $1)
if [ -z "$2" ]
then
    echo "sync_wallpaper.sh \$2 must be the wallpaper file"
    exit 1
fi
WALLPAPER_NAME="$2"
WALLPAPER="$REPO_DIR/$WALLPAPER_NAME"
echo "server.sh REPO_DIR=$REPO_DIR, Wallpaper=$WALLPAPER"

# https://askubuntu.com/questions/742870/background-not-changing-using-gsettings-from-cron
REAL_UID=$(id --real --user)
PID=$(pgrep --euid $REAL_UID gnome-session | head -n 1)
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2- | sed -e "s/\x0//g")
logger "set_wallpaper.sh UID = $REAL_UID; PID = $REAL_PID; DBUS = $DBUS_SESSION_BUS_ADDRESS"

if [ "$CREATE" == "true" ]
then
    bash "$REPO_DIR/create_wallpaper.sh" "$REPO_DIR" "$WALLPAPER_NAME"
    echo "Created new wallpaper"
fi

if [ "$SYNC" == "true" ]
then
    bash "$REPO_DIR/sync_wallpaper.sh" "$REPO_DIR" "$WALLPAPER"
    echo "synced wallpaper project"
fi

# Set last so we can sync or create to get wallpapers.
if [ "$SET" == "true" ]
then
    bash "$REPO_DIR/set_wallpaper.sh" "$WALLPAPER"
    echo "Set new wallpaper"
fi
