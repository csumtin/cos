#!/bin/bash
set -eux

if [[ $EUID -eq 0  ]]; then
  echo "This script must NOT be run as root"
  exit 1
fi

# disable everything first
keys=$(dconf list /org/gnome/terminal/legacy/keybindings/)
for key in $keys; do
    dconf write "/org/gnome/terminal/legacy/keybindings/$key" "''"
done

echo "[org/gnome/terminal/legacy/keybindings]
close-tab='<Primary>w'
copy='<Primary>c'
find='<Primary>f'
new-tab='<Primary>t'
new-window='<Primary>n'
next-tab='<Primary>Tab'
paste='<Primary>v'
prev-tab='<Primary><Shift>Tab'
select-all='<Primary>a'" | dconf load /

keys=$(dconf list /org/gnome/desktop/wm/keybindings/)
for key in $keys; do
    dconf write "/org/gnome/desktop/wm/keybindings/$key" "''"
done

echo "[org/gnome/desktop/wm/keybindings]
close=['<Primary>q']
move-to-workspace-left=['<Shift><Super>Up', '<Control><Shift><Alt>Up']
move-to-workspace-right=['<Shift><Super>Down', '<Control><Shift><Alt>Down']
switch-to-workspace-left=['<Super>Up', '<Control><Alt>Up']
switch-to-workspace-right=['<Super>Down', '<Control><Alt>Down']
toggle-fullscreen=['<Super>f']" | dconf load /

echo "[Desktop Entry]
Name=Gedit
Exec=/home/c/proj/cap/gedit/start.sh
Type=Application" > /home/c/.local/share/applications/gedit.desktop

echo "[Desktop Entry]
Name=Firefox
Exec=/home/c/proj/cap/firefox/start.sh
Type=Application" > /home/c/.local/share/applications/firefox.desktop

update-desktop-database

echo "xhost + > /dev/null" > /home/c/.bashrc
