#!/bin/bash
set -eux

if [[ $EUID -eq 0  ]]; then
  echo "This script must NOT be run as root"
  exit 1
fi

echo "[org/gnome/terminal/legacy/keybindings]
close-tab='<Primary>w'
close-window='disabled'
copy='<Primary>c'
find='<Primary>f'
find-clear='disabled'
find-next='disabled'
find-previous='disabled'
full-screen='disabled'
help='disabled'
move-tab-left='disabled'
move-tab-right='disabled'
new-tab='<Primary>t'
new-window='<Primary>n'
next-tab='<Primary>Tab'
paste='<Primary>v'
prev-tab='<Primary><Shift>Tab'
select-all='<Primary>a'
switch-to-tab-1='disabled'
switch-to-tab-10='disabled'
switch-to-tab-2='disabled'
switch-to-tab-3='disabled'
switch-to-tab-4='disabled'
switch-to-tab-5='disabled'
switch-to-tab-6='disabled'
switch-to-tab-7='disabled'
switch-to-tab-8='disabled'
switch-to-tab-9='disabled'
zoom-in='disabled'
zoom-normal='disabled'
zoom-out='disabled'" | dconf load /

echo "[org/gnome/desktop/wm/keybindings]
begin-move=@as []
begin-resize=@as []
close=['<Primary>q']
cycle-group=@as []
cycle-group-backward=@as []
cycle-panels=@as []
cycle-panels-backward=@as []
cycle-windows=@as []
cycle-windows-backward=@as []
maximize=@as []
minimize=@as []
move-to-monitor-down=@as []
move-to-monitor-left=@as []
move-to-monitor-right=@as []
move-to-monitor-up=@as []
move-to-workspace-1=@as []
move-to-workspace-last=@as []
move-to-workspace-left=['<Shift><Super>Up', '<Control><Shift><Alt>Up']
move-to-workspace-right=['<Shift><Super>Down', '<Control><Shift><Alt>Down']
panel-run-dialog=@as []
switch-applications=@as []
switch-applications-backward=@as []
switch-group=@as []
switch-group-backward=@as []
switch-input-source=@as []
switch-input-source-backward=@as []
switch-panels=@as []
switch-panels-backward=@as []
switch-to-workspace-1=@as []
switch-to-workspace-last=@as []
switch-to-workspace-left=['<Super>Up', '<Control><Alt>Up']
switch-to-workspace-right=['<Super>Down', '<Control><Alt>Down']
toggle-fullscreen=['<Super>f']
toggle-maximized=@as []
unmaximize=@as []

[org/gnome/mutter/keybindings]
toggle-tiled-left=@as []
toggle-tiled-right=@as []

[org/gnome/mutter/wayland/keybindings]
restore-shortcuts=@as []

[org/gnome/settings-daemon/plugins/media-keys]
help=@as []
logout=@as []
magnifier=@as []
magnifier-zoom-in=@as []
magnifier-zoom-out=@as []
screenreader=@as []

[org/gnome/shell/keybindings]
focus-active-notification=@as []
open-application-menu=@as []
show-screen-recording-ui=@as []
toggle-application-view=@as []
toggle-message-tray=@as []
toggle-overview=@as []" | dconf load /

echo "[Desktop Entry]
Name=Gedit
Exec=/home/c/proj/cap/gedit/start.sh
Type=Application" > /home/c/.local/share/applications/gedit.desktop

echo "[Desktop Entry]
Name=Firefox
Exec=/home/c/proj/cap/firefox/start.sh
Type=Application" > /home/c/.local/share/applications/firefox.desktop

echo "[Desktop Entry]
Name=Google-Chrome
Exec=/home/c/proj/cap/google-chrome/start.sh
Type=Application" > /home/c/.local/share/applications/google-chrome.desktop

update-desktop-database

echo "xhost + > /dev/null" > /home/c/.bashrc
