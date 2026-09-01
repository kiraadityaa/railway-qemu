#!/bin/bash

set -e

# ============================================================
# Railway environment
# ============================================================

PORT="${PORT:-8080}"

export HOME=/root
export USER=root
export DISPLAY=:1

echo "=================================================="
echo " Railway XFCE Desktop Container"
echo "=================================================="
echo "PORT    : ${PORT}"
echo "DISPLAY : ${DISPLAY}"
echo "=================================================="


# ============================================================
# Runtime directories
# ============================================================

mkdir -p /run/dbus
mkdir -p /root/.vnc


# ============================================================
# Start D-Bus system bus
# No systemd required
# ============================================================

if [ ! -S /run/dbus/system_bus_socket ]; then
    echo "[+] Starting D-Bus system bus..."
    dbus-daemon --system --fork
fi


# ============================================================
# Clean stale VNC files
# ============================================================

rm -f /tmp/.X1-lock
rm -f /tmp/.X11-unix/X1
rm -f /root/.vnc/*.pid


# ============================================================
# Start TigerVNC
# NO PASSWORD
# ============================================================

echo "[+] Starting TigerVNC without password..."

vncserver :1 \
    -geometry 1280x800 \
    -depth 24 \
    -localhost no \
    -SecurityTypes None


# ============================================================
# Wait for VNC
# ============================================================

echo "[+] Waiting for VNC..."

for i in $(seq 1 30); do
    if [ -S /tmp/.X11-unix/X1 ]; then
        break
    fi

    sleep 1
done

if [ ! -S /tmp/.X11-unix/X1 ]; then
    echo "[ERROR] VNC X11 socket was not created."
    exit 1
fi


# ============================================================
# Start noVNC
#
# Railway provides HTTPS externally.
# Container listens on plain HTTP.
# ============================================================

echo "[+] Starting noVNC on port ${PORT}..."

websockify \
    --web=/usr/share/novnc/ \
    "0.0.0.0:${PORT}" \
    "127.0.0.1:5901" &

NOVNC_PID=$!


# ============================================================
# Check noVNC
# ============================================================

sleep 2

if ! kill -0 "${NOVNC_PID}" 2>/dev/null; then
    echo "[ERROR] noVNC failed to start."
    exit 1
fi


# ============================================================
# Ready
# ============================================================

echo ""
echo "=================================================="
echo " Desktop is ready"
echo "=================================================="
echo ""
echo " Open:"
echo ""
echo "   https://YOUR-RAILWAY-DOMAIN/vnc.html"
echo ""
echo " Firefox:"
echo "   firefox"
echo ""
echo " Chromium:"
echo "   flatpak run org.chromium.Chromium"
echo ""
echo " VNC authentication:"
echo "   DISABLED"
echo ""
echo "=================================================="


# ============================================================
# Keep container alive
# ============================================================

wait "${NOVNC_PID}"
