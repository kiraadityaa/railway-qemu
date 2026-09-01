FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

# ------------------------------------------------------------
# Base system + XFCE + VNC + noVNC + D-Bus
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    xubuntu-icon-theme \
    tigervnc-standalone-server \
    tigervnc-common \
    novnc \
    websockify \
    dbus \
    dbus-x11 \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    xauth \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    xterm \
    openssl \
    ca-certificates \
    sudo \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# Firefox - Mozilla Team PPA
# Native .deb, NOT Snap
# ------------------------------------------------------------
RUN add-apt-repository ppa:mozillateam/ppa -y

RUN printf '%s\n' \
    'Package: firefox*' \
    'Pin: release o=LP-PPA-mozillateam' \
    'Pin-Priority: 1001' \
    > /etc/apt/preferences.d/mozilla-firefox

RUN apt-get update && apt-get install -y \
    firefox \
    && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# Flatpak
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    flatpak \
    && rm -rf /var/lib/apt/lists/*

# Add Flathub
RUN flatpak remote-add --if-not-exists \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Chromium from Flathub
# This is Chromium Flatpak, NOT Snap.
RUN flatpak install -y flathub org.chromium.Chromium


# ------------------------------------------------------------
# XFCE / VNC configuration
# ------------------------------------------------------------
RUN mkdir -p /root/.vnc

COPY xstartup /root/.vnc/xstartup
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /root/.vnc/xstartup \
    /entrypoint.sh


# Avoid Flatpak XDG_DATA_DIRS warning
ENV XDG_DATA_DIRS=/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:/root/.local/share/flatpak/exports/share


# VNC + noVNC
EXPOSE 5901
EXPOSE 6080

CMD ["/entrypoint.sh"]
