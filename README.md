# Antigravity Sandboxed Docker

A Dockerized environment to run the **Antigravity** Electron application safely within a sandboxed Debian container. 

This setup allows you to run the GUI application on your host Linux system (specifically optimized for **Void Linux**, **KDE Plasma**, and **Wayland/XWayland**) while keeping dependencies like Python, FFmpeg, and system libraries isolated from your main OS.

## Features

- **GUI Support:** Runs via X11 forwarding (compatible with XWayland).
- **Hardware Acceleration:** Maps `/dev/dri` for smooth rendering.
- **Persistence:** Maps a host directory to save your data permanently.
- **Pre-installed Tools:** Includes Python 3, FFmpeg, and all necessary Electron dependencies.
- **Secure:** Runs as a non-root user (UID 1000).

## Prerequisites

- **Docker** and **Docker Compose** installed.
- **X11 or XWayland** running on the host.
- **xhost** command available (usually part of `xorg-server-xinit` or `xhost` package).

## ⚠️ Important: Before Running

Every time you restart your computer (or restart your X session), you must allow Docker to communicate with your display. Run this command on your host terminal:

```bash
xhost +local:docker
```

If you do not run this, the container will start, but the window will not appear.

## Installation & Usage

### Option 1: Portainer (Recommended)

You can deploy this directly as a Stack in Portainer without downloading files manually.

1.  Log in to **Portainer**.
2.  Go to **Stacks** > **Add stack**.
3.  Name it `antigravity-stack`.
4.  Select **Web editor**.
5.  Paste the following configuration:

```yaml
services:
  antigravity:
    container_name: antigravity_gui
    build:
      # If using the repo, ensure the repo has the updated Dockerfile above!
      # If you edited the Dockerfile manually in Portainer, that works too.
      context: https://github.com/procrastinando/antigravity-sandboxed-docker.git
      dockerfile: Dockerfile
    
    # NETWORK FIX: Allows the app to receive the Google Callback on localhost
    network_mode: host

    volumes:
      - /home/user/antigravity:/home/appuser/data
      - /tmp/.X11-unix:/tmp/.X11-unix
      - /run/dbus:/run/dbus
    
    environment:
      - DISPLAY=${DISPLAY:-:0}
      - HOME=/home/appuser
      - DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
    
    devices:
      - /dev/dri:/dev/dri
    
    security_opt:
      - seccomp:unconfined
    
    restart: unless-stopped
    stdin_open: true
    tty: true
```

6.  Click **Deploy the stack**.

### Option 2: Docker Compose (CLI)

1.  Clone this repository:
    ```bash
    git clone https://github.com/procrastinando/antigravity-sandboxed-docker.git
    cd antigravity-sandboxed-docker
    ```

2.  Run the container:
    ```bash
    docker-compose up -d --build
    ```

## Persistence

The container is configured to save data to `/home/appuser/data`.
In the `docker-compose.yml`, this maps to your host directory:

`HOST: /home/user/antigravity` -> `CONTAINER: /home/appuser/data`

Any file you save inside the application to the `data` folder will persist on your laptop even if you delete the container.

## Technical Details

- **Base Image:** `debian:bookworm-slim`
- **User:** Runs as `appuser` (UID 1000, GID 1000) to match standard Linux single-user setups.
- **Dependencies Included:**
    - Python 3 + Pip + Venv
    - FFmpeg
    - `libnss3`, `libatk`, `libdrm`, `libgtk-3-0` (Standard Electron deps)

## Troubleshooting

**The window doesn't show up:**
1.  Check if you ran `xhost +local:docker` on the host.
2.  Check your display ID. Run `echo $DISPLAY` on your host. If it returns `:1`, update the environment variable in the docker-compose file to `DISPLAY=:1`.

**Permission errors on save:**
Ensure your host folder (`/home/carlos/antigravity`) exists and is owned by your user (UID 1000).