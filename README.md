# x11docker/xwayland
Run Xwayland in a Docker container. 
You don't need an X server on host, you only need either `weston` or `kwin_wayland` to be installed.
You can run in X, in Wayland or from tty / console.

 - Use x11docker to run image: https://github.com/mviereck/x11docker
  
# Examples

 - `x11docker --wayland --weston --gpu x11docker/xwayland`

To run empty Xwayland without a window manager:
 - `x11docker --wayland --weston --gpu x11docker/xwayland sleep infinity`

This example runs an X server (`Xwayland`) in container without needing any X server on host. 
As a sample X application it runs `fvwm` window manager. 
Adjust Dockerfile with your desired window manager or desktop environment, or create a new Dockerfile with `x11docker/xwayland` as a base:
```
# afterstep window manager on Xwayland
FROM x11docker/xwayland
RUN apt-get update
RUN apt-get install -y --no-install-recommends afterstep
CMD afterstep
```

# Options
 - Persistent home folder stored on host with   `--home`
 - Shared host folder with                      `--sharedir DIR`
 - Hardware acceleration with option            `--gpu`
 - Clipboard sharing with option                `--clipboard`
 - Sound support with option                    `--alsa`
 - With pulseaudio in image, sound support with `--pulseaudio`
 - Language locale settings with                `--lang [=$LANG]`

Look at `x11docker --help` for further options.

# Host applications on containered X server
You can run host applications on Xwayland in docker with:
```
mkdir /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix   # just to make sure it exists
read Xenv < <(x11docker --wayland --gpu --sharedir /tmp/.X11-unix x11docker/xwayland)
env $Xenv libreoffice
```
Be aware that directory `/tmp/.X11-unix` must already exist on host with permission `1777`.

`Xenv` will contain `DISPLAY` of Xwayland. You can specify a custom display number with option `--display N`.

You can also run a panel or another launcher to have access to all host applications. 
A quite well integration provides [`launchy`](https://www.launchy.net/) that creates a working tray icon in container desktop or can be called with `<CRTL><space>`.

***Warning***: Be aware that `--sharedir /tmp/.X11-unix` shares host X unix socket, too. 
If your host X allows access with `xhost` (check output of plain `xhost`), container applications can access it, too. 
Evil applications can abuse that for keylogging and other awfull stuff. 
***Solution:*** You can remove `xhost` authentication on host X with x11docker option `--clean-xhost`. 
Host applications then use the cookie in `XAUTHORITY` that is not available for container applications.

A one-liner using options `--display` and `--clean-xhost`, and running `launchy` from host after a delay to wait for Xwayland:
```
x11docker --display 50 \
    --clean-xhost \
    --runfromhost 'sleep 3 && DISPLAY=:50 launchy &' \
    --sharedir /tmp/.X11-unix \
    --wayland \
    --weston \
    --gpu \
    x11docker/xwayland
```

 # Screenshot
 Xwayland in Docker container running window manager `fvwm` and providing `launchy` from host:
 
 ![screenshot](https://raw.githubusercontent.com/mviereck/x11docker/screenshots/screenshot-xwayland.png "Xwayland in docker with fvwm desktop in a Weston Wayland window")
