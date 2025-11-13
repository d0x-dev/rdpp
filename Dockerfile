# Ubuntu with Windows-like desktop + RDP + Ngrok
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=administrator
ENV PASSWORD=Darkboy336

# Install Windows-like desktop (KDE Plasma)
RUN apt-get update && \
    apt-get install -y \
    kde-plasma-desktop \
    xrdp \
    firefox \
    wget \
    curl \
    unzip \
    sudo \
    net-tools && \
    apt-get clean

# Install ngrok
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz && \
    tar -xzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/ngrok && \
    rm ngrok-v3-stable-linux-amd64.tgz

# Create user
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USER

# Configure XRDP
RUN echo "startkde" > /etc/xrdp/startwm.sh && \
    sed -i 's/port=3389/port=3389\nmax_bpp=32\ndefault=yes\nuse_compression=yes/g' /etc/xrdp/xrdp.ini

EXPOSE 3389

# Start script
CMD service xrdp start && \
    ngrok tcp 3389 --authtoken $NGROK_AUTH_TOKEN --log=stdout
