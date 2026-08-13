<div align="center">

# 🖥️ Railway QEMU Mint

### Run a full Linux Mint virtual machine on Railway with QEMU + TCG + noVNC

<p>
  <img src="https://img.shields.io/badge/Railway-Deploy-8B5CF6?style=for-the-badge&logo=railway&logoColor=white" alt="Railway">
  <img src="https://img.shields.io/badge/QEMU-11.x-FF6600?style=for-the-badge&logo=qemu&logoColor=white" alt="QEMU">
  <img src="https://img.shields.io/badge/Linux-Mint-87CF3E?style=for-the-badge&logo=linuxmint&logoColor=white" alt="Linux Mint">
  <img src="https://img.shields.io/badge/noVNC-Web--based-4CAF50?style=for-the-badge" alt="noVNC">
  <img src="https://img.shields.io/badge/KVM-Disabled-orange?style=for-the-badge" alt="KVM Disabled">
</p>

<p>
  <strong>Linux Mint in your browser — powered by QEMU software emulation.</strong>
</p>

<p>
  <a href="#-features">Features</a> •
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-configuration">Configuration</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-performance">Performance</a> •
  <a href="#-troubleshooting">Troubleshooting</a>
</p>

</div>

---

## ✨ Overview

**Railway QEMU Mint** is a lightweight deployment setup for running a Linux Mint virtual machine inside a Railway container using:

- 🖥️ **QEMU** — hardware virtualization/emulation
- 🐢 **TCG** — software CPU emulation when KVM is unavailable
- 🌐 **noVNC** — browser-based graphical console
- 🚂 **Railway** — cloud deployment platform
- 💾 **Container storage** — VM disk and runtime data

The project is specifically designed for environments where:

> `/dev/kvm` is unavailable.

Instead of crashing when KVM cannot be accessed, QEMU is configured to run without hardware acceleration.

---

## 🎯 Why This Project?

Traditional QEMU deployments often assume that the host provides:

```text
/dev/kvm

That is not always available in managed container environments.

Railway containers may not expose KVM to the application container, causing conventional QEMU configurations to fail with errors similar to:

ERROR: See the FAQ for possible causes,
or disable acceleration by adding the "KVM=N" variable

This project solves that problem by explicitly disabling KVM:

KVM=N

QEMU then falls back to software emulation through TCG.


---

🧩 Architecture

┌─────────────────────────┐
                         │        Railway          │
                         │                         │
                         │      Container          │
                         │                         │
                         │  ┌───────────────────┐  │
Browser ── HTTPS ───────►│  │      noVNC        │  │
                         │  │      :8006         │  │
                         │  └─────────┬─────────┘  │
                         │            │            │
                         │            ▼            │
                         │  ┌───────────────────┐  │
                         │  │       QEMU        │  │
                         │  │                   │  │
                         │  │   Accelerator:    │  │
                         │  │       TCG         │  │
                         │  └─────────┬─────────┘  │
                         │            │            │
                         │            ▼            │
                         │  ┌───────────────────┐  │
                         │  │    Linux Mint     │  │
                         │  │     Virtual VM    │  │
                         │  └───────────────────┘  │
                         │                         │
                         └─────────────────────────┘

Request flow

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
QEMU VNC Server
   │
   ▼
Linux Mint VM


---

🚀 Features

Feature	Status

Linux Mint VM	✅
Railway deployment	✅
QEMU	✅
noVNC	✅
Browser-based desktop	✅
KVM required	❌
TCG software emulation	✅
Public Railway URL	✅
SSH support	✅
VNC support	✅
Persistent storage	⚠️ Optional
Hardware acceleration	❌



---

📦 Requirements

You only need:

A Railway account

A Git repository

Railway project/service

A public Railway domain


No KVM device is required.

No special Docker runtime configuration is required for the basic TCG setup.


---

⚡ Quick Start

1. Clone the repository

git clone https://github.com/YOUR_USERNAME/railway-qemu-mint.git

cd railway-qemu-mint


---

2. Create Dockerfile

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


---

3. Push to GitHub

git add Dockerfile README.md
git commit -m "Initial Railway QEMU Mint setup"
git push


---

4. Create a Railway project

Create a new project on Railway and deploy the repository.

Railway will automatically detect the Dockerfile.


---

5. Generate a public domain

Open:

Railway
→ Service
→ Settings
→ Networking
→ Public Networking
→ Generate Domain

After deployment, Railway will provide a public domain similar to:

https://your-project.up.railway.app


---

🌐 Accessing Linux Mint

The primary web interface is:

HTTP/HTTPS
     │
     ▼
   Port 8006
     │
     ▼
   noVNC

Open your Railway public URL in a browser.

For example:

https://your-project.up.railway.app

The noVNC interface should appear once the VM has finished booting.


---

🔌 Ports

Port	Service	Purpose

8006	noVNC	Browser-based desktop
5900	VNC	Direct VNC access
22	SSH	SSH access, if enabled


Recommended

For normal usage, use:

8006

You do not need a VNC client when using noVNC.


---

⚙️ Configuration

The VM can be customized using environment variables.

Boot OS

BOOT=mint


---

CPU

CPU_CORES=8

Increase or decrease depending on your Railway resource limits.


---

RAM

RAM_SIZE=16G

Examples:

RAM_SIZE=4G
RAM_SIZE=8G
RAM_SIZE=16G

Make sure the configured RAM is actually available to the Railway service.


---

Disk

DISK_SIZE=550G

This controls the virtual disk size used by the QEMU environment.

> A large virtual disk size does not necessarily mean that Railway provides that amount of persistent physical storage.




---

🐢 Why KVM Is Disabled

The most important configuration is:

KVM=N

Normally QEMU attempts to use:

/dev/kvm

for hardware-assisted virtualization.

However, managed container platforms may not expose KVM.

Without special handling, QEMU may stop during startup.

This project intentionally disables KVM:

KVM=N

and allows QEMU to use:

TCG

instead.


---

⚠️ TCG vs KVM

	KVM	TCG

Hardware acceleration	✅	❌
Requires /dev/kvm	✅	❌
Works without KVM	❌	✅
Performance	🚀 Fast	🐢 Slower
Suitable for managed containers	Sometimes	✅
CPU emulation	Hardware-assisted	Software


Important

TCG is significantly slower than KVM.

Desktop workloads such as:

Web browsers

Video playback

Compiling software

Large applications

Heavy multitasking


may perform considerably slower than they would on a normal KVM-backed VM.

This project prioritizes compatibility with environments without KVM.


---

💾 Storage

The default configuration does not require a Railway Volume.

The Dockerfile creates:

/storage

during image build:

RUN mkdir -p /storage

This satisfies the QEMU container startup requirement.

⚠️ Ephemeral storage

Without a Railway Volume, VM data should be considered ephemeral.

A container replacement can cause the virtual machine's storage to disappear.

If you need persistent VM data, add a Railway Volume mounted at:

/storage

Then the architecture becomes:

QEMU
 │
 ▼
/storage
 │
 ▼
Railway Volume
 │
 ▼
Persistent VM data


---

🔐 Security

This project exposes a graphical virtual machine through a public web endpoint.

Do not assume that exposing noVNC publicly is automatically secure.

Consider:

Authentication

Private networking

Access controls

HTTPS

Strong credentials

Restricting public access

Avoiding unnecessary exposed ports


If you expose VNC directly on port 5900, treat it as a sensitive service.


---

🖥️ Desktop Usage

Once Linux Mint boots, you can use the browser interface as a normal graphical desktop.

Typical workflow:

Open Railway URL
       ↓
    noVNC
       ↓
 Linux Mint login
       ↓
    Desktop
       ↓
 Applications

You can install applications inside the VM normally, subject to the VM's available resources.


---

📊 Recommended Resource Profiles

🟢 Lightweight

CPU_CORES=2
RAM_SIZE=4G
DISK_SIZE=40G

Good for:

Basic desktop

Terminal

Lightweight applications



---

🔵 Balanced

CPU_CORES=4
RAM_SIZE=8G
DISK_SIZE=80G

Good for:

General desktop usage

Lightweight development

Browsing



---

🟣 Heavy

CPU_CORES=8
RAM_SIZE=16G
DISK_SIZE=150G

Good for:

Development

Multiple applications

Larger desktop workloads


> Actual performance depends heavily on the Railway host and TCG overhead.




---

🛠️ Troubleshooting

/storage not found

Error:

ERROR: Storage folder (/storage) not found!

Make sure your Dockerfile contains:

RUN mkdir -p /storage


---

KVM unavailable

Error:

ERROR: See the FAQ for possible causes,
or disable acceleration by adding the "KVM=N" variable

Set:

KVM=N

Do not rely only on:

ARGUMENTS=-accel tcg

because the QEMU container entrypoint performs its own KVM detection before launching QEMU.


---

noVNC cannot be opened

Verify that:

8006

is exposed and that Railway has generated a public domain.

The primary web interface is:

https://YOUR-RAILWAY-DOMAIN


---

VM is extremely slow

This is expected when using:

KVM=N

because QEMU is using software emulation.

There is no Dockerfile setting that can make TCG perform exactly like KVM.

If your deployment environment eventually provides /dev/kvm, hardware acceleration can be considered.


---

Container keeps restarting

Check Railway deployment logs.

Common causes include:

/storage missing
KVM configuration
insufficient RAM
insufficient CPU
QEMU boot failure
networking configuration


---

🔧 Useful Railway Configuration

A typical deployment should look like:

Railway Project
│
└── QEMU Mint Service
    │
    ├── Dockerfile
    │
    ├── Public Networking
    │      └── :8006
    │
    ├── Environment
    │      ├── BOOT=mint
    │      ├── KVM=N
    │      ├── CPU_CORES=8
    │      ├── RAM_SIZE=16G
    │      └── DISK_SIZE=550G
    │
    └── Optional Volume
           └── /storage


---

🧪 Local Docker Test

You can also build the image locally:

docker build -t railway-qemu-mint .

Run it:

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

Then open:

http://localhost:8006


---

🗂️ Recommended Repository Structure

For the minimal deployment:

railway-qemu-mint/
│
├── Dockerfile
├── README.md
└── .gitignore

The QEMU runtime itself is provided by:

qemux/qemu

so the repository does not need to contain the entire QEMU/noVNC implementation.


---

🚀 Deployment Philosophy

This project intentionally keeps the Dockerfile extremely small.

Instead of rebuilding the complete QEMU environment:

❌ Install QEMU manually
❌ Rebuild noVNC
❌ Copy internal qemux scripts
❌ Recreate entrypoint
❌ Recreate networking
❌ Recreate VM management

we use the maintained image:

qemux/qemu

and customize only the Railway-specific requirements:

/storage
KVM=N
BOOT=mint
CPU_CORES
RAM_SIZE
DISK_SIZE

This makes the deployment easier to maintain and upgrade.


---

🧱 Dockerfile

The complete Dockerfile is:

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


---

🛡️ Limitations

This project is not intended to replace a dedicated virtualization server.

Because it uses TCG:

CPU performance is lower than KVM

Desktop responsiveness may vary

Heavy workloads may be impractical

VM storage is ephemeral without a Railway Volume

Resource limits depend on your Railway plan

Public noVNC access should be secured appropriately



---

📚 Technologies

This project is built around:

QEMU

noVNC

Linux Mint

Railway

qemux/qemu



---

🤝 Contributing

Contributions, improvements, bug reports, and deployment tips are welcome.

A good contribution should include:

1. A clear description of the problem


2. Reproduction steps


3. Railway deployment logs if relevant


4. Dockerfile changes where applicable


5. Performance information when changing QEMU settings




---

⭐ Support

If this project helps you run Linux Mint on Railway:

⭐ Star the repository

🐛 Report reproducible issues

💡 Suggest improvements

🔀 Submit pull requests



---

<div align="center">🖥️ Linux Mint in the Cloud

QEMU + TCG + noVNC + Railway

Made for environments where KVM isn't available.

<br>⭐ Star the project if you find it useful!

</div>
