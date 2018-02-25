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
# This image runs openbox on xwayland as an example application.
# Install your desired application and fill it in xinitrc below.

FROM debian:stretch-slim
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends xinit
RUN apt-get install -y xwayland mesa-utils mesa-utils-extra

# Install openbox and xterm
RUN apt-get install -y openbox xterm

# Fill in desired X applications or desktop to run.
RUN echo '\n\
openbox --sm-disable\n\
' > /xinitrc

CMD xinit /xinitrc -- /usr/bin/Xwayland :1 -retro
