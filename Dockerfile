FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

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
    unzip \
    libnss3 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    libxshmfence1 \
    libasound2 \
    libx11-xcb1 \
    libxcb1 \
    libxext6 \
    libxrender1 \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# Firefox native .deb
# ============================================================

RUN add-apt-repository ppa:mozillateam/ppa -y

RUN printf '%s\n' \
    'Package: firefox*' \
    'Pin: release o=LP-PPA-mozillateam' \
    'Pin-Priority: 1001' \
    > /etc/apt/preferences.d/mozilla-firefox

RUN apt-get update && apt-get install -y firefox \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# Chromium native binary
# No Snap
# No Flatpak
# ============================================================

RUN CHROMIUM_REV=$(curl -fsSL \
    https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/LAST_CHANGE) \
    && echo "Chromium revision: ${CHROMIUM_REV}" \
    && curl -fL \
    "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/${CHROMIUM_REV}/chrome-linux.zip" \
    -o /tmp/chromium.zip \
    && unzip -q /tmp/chromium.zip -d /opt \
    && mv /opt/chrome-linux /opt/chromium \
    && rm -f /tmp/chromium.zip


RUN cat > /usr/local/bin/chromium-browser <<'EOF'
#!/bin/bash
exec /opt/chromium/chrome \
    --no-sandbox \
    --disable-dev-shm-usage \
    "$@"
EOF

RUN chmod +x /usr/local/bin/chromium-browser

RUN ln -sf /usr/local/bin/chromium-browser /usr/local/bin/chromium


# ============================================================
# XFCE launcher
# ============================================================

RUN mkdir -p /root/.local/share/applications && \
    cat > /root/.local/share/applications/chromium.desktop <<'EOF'
[Desktop Entry]
Name=Chromium
Comment=Chromium Web Browser
Exec=/usr/local/bin/chromium %U
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF


# ============================================================
# VNC
# ============================================================

RUN mkdir -p /root/.vnc

COPY xstartup /root/.vnc/xstartup
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x \
    /root/.vnc/xstartup \
    /entrypoint.sh

EXPOSE 8080

CMD ["/entrypoint.sh"]
