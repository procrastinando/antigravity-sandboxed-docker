FROM lscr.io/linuxserver/webtop:debian-xfce

# 1. Install System Dependencies
# libxkbfile1 and libsecret-1-0 are often needed for Electron logins
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv ffmpeg \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libgtk-3-0 libgbm1 libasound2 libxcomposite1 libxdamage1 \
    libxrandr2 libxshmfence1 libxkbfile1 libsecret-1-0 \
    wget tar firefox-esr \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Download and Install Antigravity to /opt
WORKDIR /opt/antigravity
RUN wget "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.13.3-4533425205018624/linux-x64/Antigravity.tar.gz" -O app.tar.gz \
    && tar -xvf app.tar.gz --strip-components=1 \
    && rm app.tar.gz \
    && chmod +x antigravity

# 3. Create a Desktop Launcher for easy access
RUN mkdir -p /defaults/desktop && \
    echo '[Desktop Entry]\n\
Type=Application\n\
Name=Antigravity\n\
Exec=/opt/antigravity/antigravity --no-sandbox\n\
Icon=utilities-terminal\n\
Terminal=false\n\
Categories=Development;' > /defaults/desktop/antigravity.desktop && \
    chmod +x /defaults/desktop/antigravity.desktop

# Webtop uses the /config volume for everything personal
WORKDIR /config