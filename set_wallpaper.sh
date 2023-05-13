#!/bin/bash

# Change wallpaper

# Ensure a base directory was provided.
if [ -z "$1" ]
then
    echo "set_wallpaper.sh \$1 must be base directory"
    exit 1
fi
BASE_DIR="$1"
logger "set_wallpaper.sh base_dir = $BASE_DIR"
# SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# https://askubuntu.com/questions/742870/background-not-changing-using-gsettings-from-cron
REAL_UID=$(id --real --user)
PID=$(pgrep --euid $REAL_UID gnome-session | head -n 1)
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2- | sed -e "s/\x0//g")
logger "set_wallpaper.sh UID = $REAL_UID; PID = $REAL_PID; DBUS = $DBUS_SESSION_BUS_ADDRESS"

# Set path to wallpaper
WALLPAPER="$BASE_DIR/wallpaper.png"

# Remove old wallpaper
rm -f $WALLPAPER
gsettings set org.gnome.desktop.background picture-uri ""
gsettings set org.gnome.desktop.background picture-uri-dark ""

# Create new background
TEXT=$(shuf -n 1 $BASE_DIR/quotes.txt | xargs -n9)
files=( $BASE_DIR/wallpapers/* )
logger "set_wallpaper.sh Files = $files, TEXT = $TEXT"
echo "set_wallpaper.sh Files = $files, TEXT = $TEXT"
randomfile=$(printf "%s\n" "${files[RANDOM % ${#files[@]}]}")
logger "set_wallpaper.sh Setting wallpaper $randomfile with text $TEXT"
echo "set_wallpaper.sh Setting wallpaper = $randomfile, TEXT = $TEXT"
convert "$randomfile" -pointsize 70 -fill white -gravity North -annotate +0+100 "$TEXT" -quality 100 "$WALLPAPER"

# Update background
gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
gsettings set org.gnome.desktop.background picture-options "spanned"
gsettings set org.gnome.desktop.background show-desktop-icons "true"
logger "set_wallpaper.sh completed"
