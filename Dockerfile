# x11docker/xwayland
# 
# Run X server Xwayland in docker.
#
# Doesn't need X on host.
# Needs weston on host.
#   (Alternatives on host: kwin_wayland
#    or an already running Wayland compositor)
#
# Use x11docker to run image. 
# Get x11docker from github: 
#   https://github.com/mviereck/x11docker 
#
# Example: 
#
#     x11docker --wayland --gpu x11docker/xwayland
#
# Look at x11docker --help for further options.
#
# How to run host X applications on Xwayland in docker:
#   Look at https://github.com/mviereck/dockerfile-x11docker-xwayland
#
# Cumstomize window manager:
#   This image runs window manager fvwm on Xwayland.
#   Install your desired enviroment and adjust CMD.

FROM debian:stretch-slim
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-mark hold iptables && \
    apt-get -y dist-upgrade && apt-get autoremove -y && apt-get clean
RUN apt-get install -y dbus-x11 procps psmisc

# OpenGL / MESA
RUN apt-get install -y mesa-utils mesa-utils-extra libxv1

# Install locales and set to english
ENV LANG en_US.UTF-8
RUN echo $LANG UTF-8 > /etc/locale.gen
RUN apt-get install -y locales && update-locale --reset LANG=$LANG

RUN apt-get install -y --no-install-recommends xinit xauth x11-xserver-utils
RUN apt-get install -y xwayland


#### Install window manager and xterm, adjust to your needs.
#### Adjust CMD, too.
RUN apt-get install -y --no-install-recommends fvwm lxmenu-data xterm
####

RUN echo '\n\
xhost +SI:localuser:$USER >/dev/null\n\
echo "DISPLAY=$DISPLAY" \n\
unset WAYLAND_DISPLAY \n\
export XDG_SESSION_TYPE=x11 \n\
' > /xinitrc

# script to run xinit -- Xwayland
RUN echo '#! /bin/sh\n\
export DISPLAY=":$(echo $WAYLAND_DISPLAY | cut -d- -f2)" \n\
export XAUTHORITY="$HOME/.Xauthority" \n\
xauth add $DISPLAY . $(mcookie) \n\
exec xinit $HOME/xinitrc -- /usr/bin/Xwayland $DISPLAY -retro -auth $XAUTHORITY -extension MIT-SHM +extension RANDR\n\
' > /usr/local/bin/startxwayland
RUN chmod +x /usr/local/bin/startxwayland

# startscript to:
# - copy dotfiles from /etc/skel
# - entry CMD in xinitrc
# - run /usr/local/bin/startxwayland
RUN echo '#! /bin/sh\n\
[ -e "$HOME/.config" ] || cp -R /etc/skel/. $HOME/ \n\
cp /xinitrc $HOME/xinitrc \n\
echo "exec $*" >> $HOME/xinitrc \n\
exec startxwayland \n\
' > /usr/local/bin/start 
RUN chmod +x /usr/local/bin/start 


ENTRYPOINT start
CMD fvwm

ENV DEBIAN_FRONTEND newt
