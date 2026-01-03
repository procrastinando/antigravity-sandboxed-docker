# Use a lightweight Debian base
FROM debian:bookworm-slim

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install System Dependencies
# - Electron requirements (libnss3, libatk, etc)
# - Python and FFmpeg (as requested)
# - Utilities (wget, tar)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    ffmpeg \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libgtk-3-0 \
    libgbm1 \
    libasound2 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxshmfence1 \
    wget \
    tar \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup the User (Matches your Host UID 1000)
# This ensures files saved to /home/carlos/antigravity are owned by YOU, not root.
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} appgroup && \
    useradd -m -u ${USER_ID} -g appgroup appuser

# 3. Download and Install Antigravity
WORKDIR /opt/antigravity
# Using the link you provided
RUN wget "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.13.3-4533425205018624/linux-x64/Antigravity.tar.gz" -O app.tar.gz \
    && tar -xvf app.tar.gz --strip-components=1 \
    && rm app.tar.gz \
    && chmod +x antigravity

# 4. Set up the Data Directory
# We create a folder where we will mount your host storage
RUN mkdir -p /home/appuser/data && chown -R appuser:appgroup /home/appuser

# Switch to non-root user
USER appuser
WORKDIR /home/appuser/data

# 5. The Command to Start
# --no-sandbox is required for Electron in Docker
CMD ["/opt/antigravity/antigravity", "--no-sandbox"]