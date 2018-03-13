# x11docker/xwayland
# 
# Run Xwayland in docker.
#
# Use x11docker to run image. 
# Get x11docker from github: 
#   https://github.com/mviereck/x11docker 
#
# Example (needs weston or kwin_wayland on host, 
# or a running Wayland compositor like Gnome 3 Wayland session): 
#
#     x11docker --wayland --gpu x11docker/xwayland
#
# Look at x11docker --help for further options.
#
# This example runs an X server (Xwayland) in container 
# without needing any X server on host.
#
# Look at https://github.com/mviereck/dockerfile-x11docker-xwayland
# on how to run X applications from host on Xwayland in container.
#
# This image runs fvwm on Xwayland as an example desktop environment.
# Install your desired application and fill it in xinitrc below.

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
' > /xinitrc

# script to run xinit -- Xwayland
RUN echo '#! /bin/sh\n\
export DISPLAY=":$(echo $WAYLAND_DISPLAY | cut -d- -f2)" \n\
export XAUTHORITY="$HOME/.Xauthority" \n\
xauth add $DISPLAY . $(mcookie) \n\
xinit $HOME/xinitrc -- /usr/bin/Xwayland $DISPLAY -retro -auth $XAUTHORITY\n\
' > /usr/local/bin/startxwayland
RUN chmod +x /usr/local/bin/startxwayland

# startscript to:
# - copy dotfiles from /etc/skel
# - entry CMD in xinitrc
# - run /usr/local/bin/startxwayland
RUN echo '#! /bin/sh\n\
[ -e "$HOME/.config" ] || cp -R /etc/skel/. $HOME/ \n\
cp /xinitrc $HOME/xinitrc \n\
echo "$*" >> $HOME/xinitrc \n\
exec startxwayland \n\
' > /usr/local/bin/start 
RUN chmod +x /usr/local/bin/start 


ENTRYPOINT start
CMD fvwm

ENV DEBIAN_FRONTEND newt
