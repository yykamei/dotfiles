# This file is used when I use i3 window manager.
#
# Required commands:
#
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
setxkbmap -layout jp,us -model pc104 -option 'keypad:pointerkeys'

# keysym setting
xmodmap ~/.Xmodmap

# backlight setting
# modify /sys/class/backlight/intel_backlight/brightness

export GTK_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=fcitx

# start window manager
exec i3
