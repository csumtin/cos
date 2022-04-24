#!/bin/bash
set -eux

# Base install for an amd64 debian system
if [[ $EUID -ne 0  ]]; then
  echo "This script must be run as root"
  exit 1
fi

/home/c/proj/cap/cua/init.sh
/home/c/proj/cap/gedit/init.sh
/home/c/proj/cap/firefox/init.sh
/home/c/proj/cap/template/init.sh

su - c

echo "[org/gnome/terminal/legacy/keybindings]
new-tab='<Primary>t'
switch-to-tab-1='disabled'
find-previous='<Primary><Shift>g'
switch-to-tab-3='disabled'
copy='<Primary>c'
switch-to-tab-5='disabled'
switch-to-tab-4='disabled'
prev-tab='<Primary><Shift>Tab'
new-window='<Primary>n'
close-tab='<Primary>w'
find='<Primary>f'
full-screen='disabled'
close-window='disabled'
move-tab-left='disabled'
switch-to-tab-9='disabled'
find-next='<Primary>g'
move-tab-right='disabled'
switch-to-tab-10='disabled'
help='disabled'
zoom-normal='disabled'
paste='<Primary>v'
switch-to-tab-7='disabled'
find-clear='disabled'
select-all='<Primary>a'
zoom-out='disabled'
next-tab='<Primary>Tab'
switch-to-tab-6='disabled'
zoom-in='disabled'
switch-to-tab-8='disabled'
switch-to-tab-2='disabled'" | dconf load /

echo "[org/gnome/desktop/wm/keybindings]
activate-window-menu=['']
begin-move=['']
begin-resize=['']
close=['<Primary>q']
cycle-group=['']
cycle-group-backward=@as []
cycle-panels=['']
cycle-panels-backward=@as []
cycle-windows=['']
cycle-windows-backward=@as []
maximize=@as []
minimize=['']
move-to-monitor-down=['']
move-to-monitor-left=['']
move-to-monitor-right=['']
move-to-monitor-up=['']
move-to-workspace-1=['']
move-to-workspace-down=['<Shift><Super>Down', '<Control><Shift><Alt>Down']
move-to-workspace-last=['']
move-to-workspace-left=['']
move-to-workspace-right=['']
move-to-workspace-up=['<Shift><Super>Up', '<Control><Shift><Alt>Up']
panel-main-menu=@as []
panel-run-dialog=['']
switch-applications=['', '<Alt>Tab']
switch-applications-backward=@as []
switch-group=@as []
switch-group-backward=@as []
switch-input-source=@as []
switch-input-source-backward=['']
switch-panels=['']
switch-panels-backward=@as []
switch-to-workspace-1=['']
switch-to-workspace-down=['<Super>Down', '<Control><Alt>Down']
switch-to-workspace-last=['']
switch-to-workspace-left=['']
switch-to-workspace-right=['']
switch-to-workspace-up=['<Super>Up', '<Control><Alt>Up']
toggle-fullscreen=['<Super>f']
toggle-maximized=['']
unmaximize=@as [] | dconf load /

echo "[org/gnome/settings-daemon/plugins/power]
power-button-action='interactive'
idle-dim=false
sleep-inactive-battery-type='nothing'
sleep-inactive-ac-type='nothing'" | dconf load /

echo "[org/gnome/desktop/peripherals/mouse]
speed=0.47794117647058831" | dconf load /

echo "[Desktop Entry]
Name=Gedit
Exec=/home/c/proj/cap/gedit/start.sh
Type=Application" > /home/c/.local/share/applications/gedit.desktop

echo "[Desktop Entry]
Name=Firefox
Exec=/home/c/proj/cap/firefox/start.sh
Type=Application" > /home/c/.local/share/applications/firefox.desktop

update-desktop-database
