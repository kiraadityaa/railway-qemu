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
