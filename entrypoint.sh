#!/bin/bash

set -e

export HOME=/root
export USER=root

echo "=========================================="
echo " Starting Ubuntu XFCE container"
echo "=========================================="

# ------------------------------------------------------------
# Prepare runtime directories
# ------------------------------------------------------------
mkdir -p /run/dbus
mkdir -p /root/.vnc

# ------------------------------------------------------------
# Start D-Bus system bus
# No systemd required
# ------------------------------------------------------------
if [ ! -S /run/dbus/system_bus_socket ]; then
    echo "[+] Starting D-Bus system bus..."
    dbus-daemon --system --fork
else
    echo "[+] D-Bus system bus already running"
fi

# ------------------------------------------------------------
# Remove stale VNC lock / PID files
# ------------------------------------------------------------
rm -f /tmp/.X1-lock
rm -f /tmp/.X11-unix/X1
rm -f /root/.vnc/*.pid

# ------------------------------------------------------------
# Generate VNC password file if it does not exist
# ------------------------------------------------------------
if [ ! -f /root/.vnc/passwd ]; then
    echo "[+] Creating VNC password file..."

    # Password: change-this
    mkdir -p /root/.vnc

    printf '%s\n' 'change-this' | \
        vncpasswd -f > /root/.vnc/passwd

    chmod 600 /root/.vnc/passwd
fi

# ------------------------------------------------------------
# Start TigerVNC
# ------------------------------------------------------------
echo "[+] Starting TigerVNC..."

vncserver :1 \
    -geometry 1024x768 \
    -depth 24 \
    -localhost no \
    -SecurityTypes VncAuth

# ------------------------------------------------------------
# Create self-signed certificate for noVNC
# ------------------------------------------------------------
if [ ! -f /root/self.pem ]; then
    echo "[+] Creating noVNC certificate..."

    openssl req \
        -new \
        -x509 \
        -nodes \
        -days 3650 \
        -subj "/C=ID/O=Docker/OU=XFCE/CN=localhost" \
        -keyout /root/self.key \
        -out /root/self.crt

    cat /root/self.key /root/self.crt > /root/self.pem
fi

# ------------------------------------------------------------
# Start noVNC
# ------------------------------------------------------------
echo "[+] Starting noVNC on port 6080..."

websockify \
    --web=/usr/share/novnc/ \
    --cert=/root/self.pem \
    6080 \
    localhost:5901 &

echo ""
echo "=========================================="
echo " Container is ready"
echo "=========================================="
echo ""
echo " XFCE / noVNC:"
echo " http://localhost:6080/vnc.html"
echo ""
echo " VNC:"
echo " localhost:5901"
echo ""
echo " Firefox:"
echo " firefox"
echo ""
echo " Chromium:"
echo " flatpak run org.chromium.Chromium"
echo ""
echo "=========================================="

# Keep container alive
wait
