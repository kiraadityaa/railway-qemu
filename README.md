<div align="center">

# Railway QEMU Mint

**Run a full Linux Mint virtual machine on Railway using QEMU software emulation and noVNC.**

[![Railway](https://img.shields.io/badge/Railway-Deploy-8B5CF6?style=flat-square&logo=railway&logoColor=white)](https://railway.app)
[![QEMU](https://img.shields.io/badge/QEMU-11.x-FF6600?style=flat-square)](https://www.qemu.org/)
[![Linux Mint](https://img.shields.io/badge/Linux%20Mint-latest-87CF3E?style=flat-square&logo=linuxmint&logoColor=white)](https://linuxmint.com/)

</div>

---

## Overview

Railway QEMU Mint deploys a Linux Mint desktop accessible from any browser. It is built specifically for managed container environments where `/dev/kvm` is not available. Rather than failing on missing hardware acceleration, the setup explicitly falls back to QEMU's software CPU emulation (TCG) via:

```
KVM=N
```

The stack:

| Component | Role |
|-----------|------|
| **QEMU** | Hardware emulation |
| **TCG** | Software CPU backend when KVM is unavailable |
| **noVNC** | Browser-based graphical console |
| **Railway** | Cloud container platform |

---

## Architecture

```
Browser
  │
  │ HTTPS
  ▼
Railway Public Domain
  │
  │ :8006
  ▼
noVNC
  │
  │ WebSocket
  ▼
QEMU VNC Server (TCG)
  │
  ▼
Linux Mint VM
  │
  ▼
/storage  (ephemeral by default, persistent with Railway Volume)
```

---

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/railway-qemu-mint.git
cd railway-qemu-mint
```

### 2. Create the Dockerfile

```dockerfile
FROM qemux/qemu:latest

RUN mkdir -p /storage

ENV KVM="N"
ENV BOOT="mint"
ENV CPU_CORES="8"
ENV RAM_SIZE="16G"
ENV DISK_SIZE="550G"

EXPOSE 22
EXPOSE 5900
EXPOSE 8006
```

### 3. Push to GitHub

```bash
git add Dockerfile README.md
git commit -m "Initial Railway QEMU Mint setup"
git push
```

### 4. Create a Railway project

Create a new project on Railway, connect your repository, and deploy. Railway auto-detects the Dockerfile.

### 5. Generate a public domain

```
Railway → Service → Settings → Networking → Public Networking → Generate Domain
```

Your VM will be accessible at:

```
https://your-project.up.railway.app
```

---

## Accessing the Desktop

Open your Railway public URL in a browser. The noVNC interface loads once the VM finishes booting. No VNC client is needed.

**Default login flow:**

```
Railway URL → noVNC → Linux Mint login screen → Desktop
```

---

## Ports

| Port | Service | Notes |
|------|---------|-------|
| `8006` | noVNC | Primary browser access |
| `5900` | VNC | Direct VNC client access |
| `22` | SSH | Optional SSH access |

For normal use, only port `8006` is needed.

---

## Configuration

All configuration is done through environment variables.

| Variable | Default | Description |
|----------|---------|-------------|
| `BOOT` | `mint` | OS to boot |
| `CPU_CORES` | `8` | Number of virtual CPU cores |
| `RAM_SIZE` | `16G` | RAM allocated to the VM |
| `DISK_SIZE` | `550G` | Virtual disk size |
| `KVM` | `N` | Must remain `N` on Railway |

> **Note:** A large `DISK_SIZE` does not mean Railway provides that amount of persistent physical storage. The virtual disk is backed by the container filesystem, which is ephemeral unless a Railway Volume is attached.

---

## KVM vs. TCG

QEMU normally uses `/dev/kvm` for hardware-assisted virtualization. Railway containers do not expose this device, so KVM must be explicitly disabled:

```
KVM=N
```

This switches QEMU to **TCG** (Tiny Code Generator), a software CPU emulator.

| | KVM | TCG |
|---|---|---|
| Hardware acceleration | Yes | No |
| Requires `/dev/kvm` | Yes | No |
| Works in managed containers | Sometimes | Yes |
| Performance | Fast | Slower |

TCG is slower than KVM. CPU-intensive tasks — compiling, video playback, heavy multitasking — will be noticeably slower than on a KVM-backed VM. This setup prioritizes compatibility over performance.

---

## Resource Profiles

### Lightweight

```dockerfile
ENV CPU_CORES="2"
ENV RAM_SIZE="4G"
ENV DISK_SIZE="40G"
```

Suitable for: terminal usage, lightweight applications.

### Balanced

```dockerfile
ENV CPU_CORES="4"
ENV RAM_SIZE="8G"
ENV DISK_SIZE="80G"
```

Suitable for: general desktop use, light development, browsing.

### Heavy

```dockerfile
ENV CPU_CORES="8"
ENV RAM_SIZE="16G"
ENV DISK_SIZE="150G"
```

Suitable for: development, multiple applications, larger workloads.

Actual performance depends on Railway's host resources and TCG overhead.

---

## Storage

The Dockerfile creates `/storage` at build time:

```dockerfile
RUN mkdir -p /storage
```

Without a Railway Volume, this directory — and the VM's disk — is **ephemeral**. Data is lost when the container restarts.

To persist VM data, attach a Railway Volume mounted at `/storage`:

```
Railway → Service → Volumes → Add Volume → Mount path: /storage
```

---

## Local Testing

Build and run locally with Docker:

```bash
docker build -t railway-qemu-mint .

docker run --rm \
  -p 8006:8006 \
  -p 5900:5900 \
  -p 2222:22 \
  -e KVM=N \
  -e BOOT=mint \
  -e CPU_CORES=4 \
  -e RAM_SIZE=8G \
  -e DISK_SIZE=80G \
  railway-qemu-mint
```

Then open: `http://localhost:8006`

---

## Railway Service Layout

```
Railway Project
└── QEMU Mint Service
    ├── Dockerfile
    ├── Public Networking → :8006
    ├── Environment
    │   ├── BOOT=mint
    │   ├── KVM=N
    │   ├── CPU_CORES=8
    │   ├── RAM_SIZE=16G
    │   └── DISK_SIZE=550G
    └── Volume (optional)
        └── /storage
```

---

## Troubleshooting

**`ERROR: Storage folder (/storage) not found!`**

Add to your Dockerfile:
```dockerfile
RUN mkdir -p /storage
```

**`ERROR: ... or disable acceleration by adding the "KVM=N" variable`**

Set `KVM=N` as an environment variable. Do not rely solely on `-accel tcg` in QEMU arguments — the container entrypoint performs its own KVM check before launching QEMU.

**noVNC page does not load**

Verify port `8006` is exposed and that a Railway public domain has been generated.

**VM is very slow**

This is expected behavior with `KVM=N`. TCG software emulation has inherent overhead. There is no configuration that makes TCG match KVM performance.

**Container keeps restarting**

Check Railway deployment logs. Common causes: missing `/storage`, insufficient RAM or CPU allocation, KVM misconfiguration, QEMU boot failure.

---

## Security

noVNC exposes a full graphical desktop through a public URL. Before deploying to production:

- Enable authentication on the noVNC interface
- Use HTTPS (Railway provides this by default)
- Avoid exposing port `5900` publicly without a VPN or firewall
- Set strong credentials for the Linux Mint user account
- Restrict public access if the VM contains sensitive data

---

## Design Philosophy

The Dockerfile is intentionally minimal. Rather than rebuilding QEMU, noVNC, or the container entrypoint from scratch, this project extends the maintained [`qemux/qemu`](https://github.com/qemux/qemu-docker) image and applies only the Railway-specific configuration:

- `/storage` directory creation
- `KVM=N` to disable hardware acceleration
- Environment variables for OS, CPU, RAM, and disk

This keeps the deployment easy to maintain and straightforward to upgrade when `qemux/qemu` releases new versions.

---

## Repository Structure

```
railway-qemu-mint/
├── Dockerfile
├── README.md
└── .gitignore
```

---

## Requirements

- A Railway account
- A GitHub repository
- A Railway public domain (generated in service settings)

No KVM device or special Docker runtime configuration is required.

---

## Limitations

- CPU performance is lower than KVM-backed VMs
- Desktop responsiveness may be reduced under TCG
- Heavy workloads (compiling, video, large applications) may be impractical
- VM storage is ephemeral without a Railway Volume
- Resource limits are constrained by your Railway plan

---

## Contributing

Contributions are welcome. A useful contribution includes:

1. A clear description of the problem or improvement
2. Steps to reproduce (for bugs)
3. Railway deployment logs if relevant
4. Dockerfile changes where applicable
5. Performance notes when modifying QEMU settings

---

## Technologies

- [QEMU](https://www.qemu.org/)
- [noVNC](https://novnc.com/)
- [Linux Mint](https://linuxmint.com/)
- [Railway](https://railway.app/)
- [qemux/qemu](https://github.com/qemux/qemu-docker)
