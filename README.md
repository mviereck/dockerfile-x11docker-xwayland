# x11docker/xwayland
Run Xwayland in docker. You don't need any X server on host, you only need a wayland compositor like `weston` or `kwin_wayland` to be installed, or any other Wayland compositor already running.

 - Use x11docker to run image. 
 - Get x11docker from github: 
  https://github.com/mviereck/x11docker 
  
# Example 
Needs `weston` or `kwin_wayland` on host to be installed, or a running Wayland compositor like `Gnome 3 Wayland session`: 
```
x11docker --wayland --gpu x11docker/xwayland
```
Look at `x11docker --help` for further options.

This example runs an X server (`Xwayland`) in container without needing any X server on host. As a sample X application it runs `openbox` window manager. Adjust Dockerfile with your desired X applications.

# Host applications on containered X server
You can run host applications on Xwayland in docker with:
```
read Xenv < <(x11docker --wayland --gpu x11docker/xwayland)
env $Xenv firefox
```
