# x11docker/xwayland
Run Xwayland in docker. You don't need any X server on host, you only need either `weston` or `kwin_wayland` to be installed, or any Wayland compositor like `Gnome 3 Wayland session` already running.
If `weston` or `kwin_wayland` are installed on host, you can also run from tty / console.

 - Use x11docker to run image. 
 - Get x11docker from github: 
  https://github.com/mviereck/x11docker 
  
# Examples

 - `x11docker --wayland --gpu x11docker/xwayland`

Explicitly using `weston`: 
 - `x11docker --weston --gpu x11docker/xwayland`
 
Explicitly using `kwin_wayland`: 
 - `x11docker --kwin --gpu x11docker/xwayland`

This example runs an X server (`Xwayland`) in container without needing any X server on host. As a sample X application it runs `fvwm` window manager. Adjust Dockerfile with your desired X applications.

# Options:
 - Persistent home folder stored on host with   `--home`
 - Shared host folder with                      `--sharedir DIR`
 - Hardware acceleration with option            `--gpu`
 - Clipboard sharing with option                `--clipboard`
 - Sound support with option                    `--alsa`
 - With pulseaudio in image, sound support with `--pulseaudio`
 - Language locale settings with                `--lang $LANG`

Look at `x11docker --help` for further options.

# Host applications on containered X server
You can run host applications on Xwayland in docker with:
```
read Xenv < <(x11docker --wayland --gpu --stdout --sharedir /tmp/.X11-unix x11docker/xwayland)
env $Xenv firefox
```
Be aware that directory `/tmp/.X11-unix` must already exist with permission `1777`.

`Xenv` will contain `DISPLAY` of Xwayland. To specify a custom display number, you can use option `--display N`.

You can also run a panel or another launcher to have access to all host applications. A quite well integration provides [`launchy`](https://www.launchy.net/) that creates a working tray icon in container desktop or can be called with `<CRTL><space>`.
 # Screenshot
 Xwayland in docker with fvwm desktop in a Weston Wayland window:
 
 ![screenshot](https://raw.githubusercontent.com/mviereck/x11docker/screenshots/screenshot-xwayland.png "Xwayland in docker with fvwm desktop in a Weston Wayland window")
