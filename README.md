# Intel Arc-Accelerated PyTorch in a Browser-Based “Computer”

Got a shiny Intel Core Ultra laptop or a dedicated Arc GPU?  
The silicon is ready, but wrestling AI stacks on a rolling-release Linux host (Void, Arch …) can feel like defusing a bomb every time a driver or Python package updates.

What if you could spin up a clean Ubuntu 24.04 desktop **inside your browser**, give it full hardware acceleration, and trash the Python environment without ever touching your host?

Let’s build exactly that with:

* Docker
* LinuxServer.io Webtop (Selkies)
* Intel Compute Runtimes (Level Zero)

## End state

Open [https://localhost:3001](https://localhost:3001) and you have:

* Fully isolated desktop
* Intel Arc / iGPU passed through
* PyTorch 2.9+ (XPU) with native Intel acceleration
* Persistent `~/data` folder (destroy the container → data lives)
* Example: run the classic “antigravity” sketch

## Why Ubuntu 24.04 “Noble”?

Stock Docker images usually ship stale compute runtimes.  
Noble has the freshest Intel graphics stack and official Intel packages.

## 1. Dockerfile

```dockerfile
# We use Ubuntu Noble (24.04)
FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install prerequisites
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    lsb-release \
    software-properties-common \
    nano \
    htop \
    curl \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# 2. Add Official Intel Graphics Repository
RUN wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg && \
    echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble unified" | tee /etc/apt/sources.list.d/intel-gpu-noble.list

# 3. Install Intel ARC Drivers
RUN apt-get update && apt-get install -y \
    intel-opencl-icd \
    libze-intel-gpu1 \
    libze1 \
    intel-media-va-driver-non-free \
    libmfx1 \
    libmfx-gen1.2 \
    clinfo \
    && rm -rf /var/lib/apt/lists/*

# 4. Install Antigravity
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
    gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
    tee /etc/apt/sources.list.d/antigravity.list > /dev/null

RUN apt-get update && \
    apt-get install -y antigravity && \
    rm -rf /var/lib/apt/lists/*
```

## 2. docker-compose.yml

Map the GPU, set the right permissions, disable nested Docker.

```yaml
services:
  webtop:
    build: https://github.com/procrastinando/antigravity-sandboxed-docker.git.
    container_name: webtop
    privileged: true
    security_opt:
      - seccomp=unconfined
    environment:
      - PUID=1000
      - PGID=13
      - TZ=Europe/Berlin
      - SUBFOLDER=/
      - TITLE=Antigravity-AI
      - START_DOCKER=false 
      # -----------------------
      - DRINODE=/dev/dri/renderD128
      - DEVICE=/dev/dri/renderD128
      - LIBVA_DRIVER_NAME=iHD
    volumes:
      - /home/carlos/antigravity/:/config
      - /var/run/docker.sock:/var/run/docker.sock
    devices:
      - /dev/dri:/dev/dri
      # - /dev/accel:/dev/accel  <-- Keep commented if you don't have this yet
    ports:
      - 3001:3001
    shm_size: "24gb"
    restart: unless-stopped
```

Launch:

```bash
docker compose up -d --build
```

Browse to [https://localhost:3001](https://localhost:3001) – full XFCE desktop, 60 FPS, GPU-accelerated.

## 3. Install PyTorch with Intel XPU

Inside the browser desktop:

```bash
python3 -m venv /config/ai-env
source /config/ai-env/bin/activate
pip install --pre torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/xpu
```

Verify:

```bash
python -c "import torch, sys, platform
print('PyTorch:', torch.__version__)
print('XPU available:', torch.xpu.is_available())
print('Python:', sys.version.split()[0], 'on', platform.platform())"
```

Expected:

```
PyTorch: 2.9.1+xpu
XPU available: True
```

## 4. Why bother?

* Host stays spotless – no Python or driver pollution
* Zip `./data`, move to any Intel-GPU box → instant lab restore
* Selkies uses the GPU for video encode → buttery remote desktop *while* the same GPU crunches models

A containerized, browser-accessible, Intel-accelerated AI workstation in ~5 minutes.