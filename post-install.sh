#!/bin/bash

cd /home/c

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
switch-to-workspace-up=['<Super>Up', '<Control><Alt>Up']
move-to-workspace-left=['']
move-to-monitor-right=['']
begin-move=['']
switch-to-workspace-left=['']
switch-to-workspace-1=['']
move-to-monitor-left=['']
panel-run-dialog=['']
toggle-maximized=['']
cycle-windows=['']
unmaximize=['', '<Alt>F5']
maximize=['<Super>m']
toggle-fullscreen=['<Super>f']
begin-resize=['']
panel-main-menu=['', '<Alt>F1']
cycle-windows-backward=@as []
cycle-group-backward=@as []
cycle-panels-backward=@as []
switch-input-source=@as []
switch-to-workspace-right=['']
move-to-workspace-down=['<Shift><Super>Down', '<Control><Shift><Alt>Down']
move-to-workspace-1=['']
cycle-group=['']
move-to-workspace-last=['']
switch-applications=['', '<Alt>Tab']
minimize=['']
switch-to-workspace-down=['<Super>Down', '<Control><Alt>Down']
switch-panels-backward=@as []
switch-applications-backward=@as []
move-to-monitor-down=['']
activate-window-menu=['']
cycle-panels=['']
move-to-workspace-up=['<Shift><Super>Up', '<Control><Shift><Alt>Up']
move-to-workspace-right=['']
switch-panels=['']
switch-input-source-backward=['']
close=['<Primary>q']
switch-to-workspace-last=['']
move-to-monitor-up=['']" | dconf load /

echo "[org/gnome/settings-daemon/plugins/power]
power-button-action='interactive'
idle-dim=false
sleep-inactive-battery-type='nothing'
sleep-inactive-ac-type='nothing'" | dconf load /

echo "[org/gnome/desktop/peripherals/mouse]
speed=0.47794117647058831" | dconf load /

mkdir -p projects/everyday

mkdir projects/everyday/gedit
cp ccs/everyday/gedit/*.sh projects/everyday/gedit

echo "[Desktop Entry]
Name=Gedit
Exec=/home/c/projects/everyday/gedit/start.sh
Type=Application" > /home/c/.local/share/applications/gedit.desktop

mkdir projects/everyday/firefox
cp ccs/everyday/firefox/*.sh projects/everyday/firefox

echo "[Desktop Entry]
Name=Firefox
Exec=/home/c/projects/everyday/firefox/start.sh
Type=Application" > /home/c/.local/share/applications/firefox.desktop

update-desktop-database

wget https://github.com/F-i-f/soft-brightness/releases/download/v21/soft-brightness@fifi.org.v21.shell-extension.zip
mkdir -p .local/share/gnome-shell/extensions/soft-brightness@fifi.org
mv soft-brightness@fifi.org.v21.shell-extension.zip .local/share/gnome-shell/extensions/soft-brightness@fifi.org
cd .local/share/gnome-shell/extensions/soft-brightness@fifi.org
unzip soft-brightness@fifi.org.v21.shell-extension.zip

echo "[org/gnome/shell]
enabled-extensions=['soft-brightness@fifi.org']" | dconf load /

echo "[org/gnome/shell/extensions/soft-brightness]
use-backlight=true
builtin-monitor='Built-in display'
current-brightness=0.66419605217357669" | dconf load /
