# This file is used when I use i3 window manager.
#
# Required commands:
#
# * xautolock (configured in i3)
# * xsetroot
# * xset
# * setxkbmap
# * xkbset
# * xmodmap
# * fcitx-mozc
# * i3

# mouse cursor setting
xsetroot -cursor_name left_ptr

# set the keyboard repeat setting
xset r rate 200 50

# set LANG
export LANG="en_US.UTF8"

# Font configuration
export XDG_CONFIG_HOME=$HOME/.config

# set keyboard layout - Must be before xmodmap
setxkbmap -layout us,jp -model pc104 -option 'keypad:pointerkeys'

# NOTE: This disables touchpad!
synclient TouchpadOff=1

# keysym setting
xmodmap ~/.Xmodmap

# backlight setting
# modify /sys/class/backlight/intel_backlight/brightness

# Set IBM TrackPoint configuration
#
# NOTE: Device id can be confirmed by `xinput list`.
#
xinput --set-prop 'TPPS/2 IBM TrackPoint' 'libinput Accel Speed' -0.1

# Set TouchPad configuration
#
# NOTE: Device id can be confirmed by `xinput list`.
#
xinput --set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Accel Speed' 1
xinput --set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Tapping Enabled' 1
xinput --set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Disable While Typing Enabled' 1

export GTK_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=fcitx

# start window manager
exec i3
