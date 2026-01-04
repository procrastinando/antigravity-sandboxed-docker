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