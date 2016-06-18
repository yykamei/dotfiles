# This file is used when I use i3 window manager.
#
# Required commands:
#
# * xsetroot
# * xset
# * setxkbmap
# * xkbset
# * xmodmap
# * ibus-daemon
# * i3
#

# mouse cursor setting
xsetroot -cursor_name left_ptr

# set the keyboard repeat setting
xset r rate 200 50

# set LANG
export LANG="ja_JP.UTF8"

# Font configuration
export XDG_CONFIG_HOME=$HOME/.config

# set keyboard layout - Must be before xmodmap
setxkbmap -layout jp,us -model pc104 -option 'keypad:pointerkeys'

# set mousekey speed
xkbset ma 15 15 20 30 10

# keysym setting
xmodmap ~/.Xmodmap

# screen saver
#xscreensaver -nosplash &
# we use i3lock

# backlight setting
# modify /sys/class/backlight/intel_backlight/brightness

export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
# ibus-daemon
ibus-daemon -dxr

# ssh-agent for X window
eval `ssh-agent`

# start window manager
exec /usr/bin/i3
