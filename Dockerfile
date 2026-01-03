FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Dependencies
# Added: firefox-esr (for login), xdg-utils (to launch it), libxkbfile1 (to fix keymap error)
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv ffmpeg \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libgtk-3-0 libgbm1 libasound2 libxcomposite1 libxdamage1 \
    libxrandr2 libxshmfence1 wget tar \
    libxkbfile1 \
    xdg-utils \
    firefox-esr \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup User
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} appgroup && \
    useradd -m -u ${USER_ID} -g appgroup appuser

# 3. Download and Install Antigravity
WORKDIR /opt/antigravity
RUN wget "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.13.3-4533425205018624/linux-x64/Antigravity.tar.gz" -O app.tar.gz \
    && tar -xvf app.tar.gz --strip-components=1 \
    && rm app.tar.gz \
    && chmod +x antigravity

# 4. Permissions
RUN mkdir -p /home/appuser/data && chown -R appuser:appgroup /home/appuser

USER appuser
WORKDIR /home/appuser/data

# 5. Launch
CMD ["/opt/antigravity/antigravity", "--no-sandbox"]