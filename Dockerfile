# x11docker/xwayland
# 
# Run X server Xwayland in docker.
#
# Doesn't need X on host.
# Needs weston on host.
#
# Use x11docker to run image: https://github.com/mviereck/x11docker 
#
# Example: 
#
#     x11docker --wayland --gpu x11docker/xwayland
#
# Look at x11docker --help for further options.
#
# How to run host X applications on Xwayland in Docker container:
#   Look at https://github.com/mviereck/dockerfile-x11docker-xwayland
#
# Cumstomize window manager:
#   This image runs window manager fvwm on Xwayland.
#   Install your desired enviroment and adjust CMD.

FROM debian:bullseye-slim

RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y \
      dbus-x11 \
      libxv1 \
      mesa-utils \
      mesa-utils-extra \
      psmisc \
      procps

# Install locales and set to english
ENV LANG en_US.UTF-8
RUN echo $LANG UTF-8 > /etc/locale.gen && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y locales && \
    env DEBIAN_FRONTEND=noninteractive update-locale --reset LANG=$LANG

RUN env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      xauth \
      xinit \
      x11-xserver-utils && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y \
      xwayland


#### Install window manager and xterm, adjust to your needs.
RUN apt-get install -y \
      fvwm \
      xterm
CMD ["fvwm"]

#RUN apt-get install -y --no-install-recommends \
#      fvwm-crystal \
#      xterm
#CMD ["fvwm-crystal"]

#RUN apt-get install -y --no-install-recommends \
#      afterstep \
#      asclock \
#      lynx \
#      mc \
#      medit \
#      rox-filer \
#      wmcalc \
#      wmcpuload \
#      xterm
#CMD ["afterstep"]
####


RUN echo '\n\
xhost +SI:localuser:$USER >/dev/null\n\
echo "DISPLAY=$DISPLAY" \n\
echo "\n\
Note: Xwayland fails if executed directly in compositor Sway. \n\
In that case try:  x11docker --weston -- x11docker/xwayland" >&2\n\
unset WAYLAND_DISPLAY \n\
unset GDK_BACKEND QT_QPA_PLATFORM CLUTTER_BACKEND SDL_VIDEODRIVER ELM_DISPLAY ELM_ACCEL ECORE_EVAS_ENGINE \n\
export XDG_SESSION_TYPE=x11 \n\
' > /xinitrc

# script to run xinit -- Xwayland
RUN echo '#! /bin/sh\n\
[ -z "$WAYLAND_DISPLAY" ] && echo "ERROR: WAYLAND_DISPLAY is not set. Need Wayland environment." >&2 && exit 1 \n\
export DISPLAY=":$(echo $WAYLAND_DISPLAY | cut -d- -f2)" \n\
export XAUTHORITY="$HOME/.Xauthority" \n\
touch $XAUTHORITY \n\
xauth add $DISPLAY . $(mcookie) \n\
exec xinit $HOME/xinitrc -- /usr/bin/Xwayland $DISPLAY -retro -auth $XAUTHORITY -extension MIT-SHM +extension RANDR\n\
' > /usr/local/bin/startxwayland && \
chmod +x /usr/local/bin/startxwayland

# startscript to:
# - entry CMD in xinitrc
# - run /usr/local/bin/startxwayland
RUN echo '#! /bin/sh\n\
cp /xinitrc $HOME/xinitrc \n\
echo "exec \"$@\"" >> $HOME/xinitrc \n\
exec startxwayland \n\
' > /usr/local/bin/start && \
chmod +x /usr/local/bin/start 

ENTRYPOINT ["/usr/local/bin/start"]
