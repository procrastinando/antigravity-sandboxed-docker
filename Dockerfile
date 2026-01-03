# Use the Selkies GStreamer Debian base (high performance web GUI)
FROM ghcr.io/selkies-project/selkies-gstreamer/debian-vnc:bookworm

USER root

# 1. Install Antigravity Dependencies + Python + FFmpeg + Firefox (for login)
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv ffmpeg \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libgtk-3-0 libgbm1 libasound2 libxcomposite1 libxdamage1 \
    libxrandr2 libxshmfence1 wget tar \
    libxkbfile1 libx11-xcb1 \
    firefox-esr \
    xdg-utils \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Download and Install Antigravity
WORKDIR /opt/antigravity
RUN wget "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.13.3-4533425205018624/linux-x64/Antigravity.tar.gz" -O app.tar.gz \
    && tar -xvf app.tar.gz --strip-components=1 \
    && rm app.tar.gz \
    && chmod +x antigravity

# 3. Setup Persistence & Permissions
# Selkies base uses 'user' (UID 1000) as the default user
RUN mkdir -p /home/user/data && chown -R user:user /home/user /opt/antigravity

# 4. Set the Autostart command
# This tells Selkies to launch Antigravity when the desktop starts
ENV START_COMMAND="/opt/antigravity/antigravity --no-sandbox"

USER user
WORKDIR /home/user/data