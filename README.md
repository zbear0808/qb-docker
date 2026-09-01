# qBittorrent + Jackett + FlareSolverr + PIA VPN Stack

This repository contains a Docker Compose configuration for a media downloading stack. It routes the traffic for **qBittorrent** securely through a Private Internet Access (PIA) VPN using [Gluetun](https://github.com/qdm12/gluetun), while **Jackett** and **FlareSolverr** use the standard host network to bypass the VPN for better compatibility and search performance.

## Prerequisites
- **Docker** and **Docker Compose** installed on your system.
- An active **Private Internet Access (PIA)** subscription.
- Git, so you can clone this repo to your machine

---

## Setup on Different Operating Systems

### Linux
1. Install Docker and Docker Compose via your package manager or the official Docker installation script.
2. Ensure your user is part of the `docker` group.
3. Find your user ID and group ID by running `id -u` and `id -g` in the terminal. Use these values for `PUID` and `PGID` in your `.env` file to prevent file permission issues.

### Windows (not recommended as it'll use alot of ram)
1. Install **Docker Desktop** and enable the **WSL 2** backend.
2. Install a WSL 2 distribution (like Ubuntu) from the Microsoft Store.
3. For significantly better performance, clone this repository inside your WSL 2 file system (e.g., `\\wsl$\Ubuntu\home\user\qb-docker`) rather than the native Windows file system (`C:\`).
4. Open the folder in WSL and run your Docker commands from there. `PUID` and `PGID` can usually be left as `1000`.

### macOS
1. Install **Docker Desktop** for Mac.
2. Ensure you have given Docker Desktop access to the folders where you plan to store your downloads (configured in Docker Desktop settings under Resources -> File sharing).
3. `PUID` and `PGID` can generally be left as `1000`.

---

#  Getting Started

1. **Configure Environment Variables:**
   Copy the example file to create your actual `.env` file:
   ```bash
   cp .env.example .env
   ```
   Open the `.env` file and fill in your **PIA Username** and **PIA Password**.

2. **Start the Stack:**
   Run the following command to download the images and start the containers in the background:
   ```bash
   docker compose up -d
   ```

---

## ⚙️ Post-Startup Configuration (Automated)

This stack is pre-configured with automation scripts that run every time the containers start. You do not need to manually configure passwords or API URLs!

### 1. qBittorrent
- **Access the Web UI:** Go to `http://localhost:8080` in your browser.
- **Authentication:** The Web UI is automatically configured to bypass authentication when accessed from your local network or via a Tailscale VPN. You will not be prompted for a password.

### 2. Jackett
- **Access the Web UI:** Go to `http://localhost:9117`
- **Authentication:** Jackett natively has no password on the local network, and this is enforced automatically.
- **FlareSolverr Integration:** Jackett is automatically pre-configured to use the FlareSolverr API. No manual setup is required.

### 3. Configuring Jackett Indexers

Because qBittorrent relies on Jackett for search, you need to configure your preferred torrent trackers (Indexers) inside Jackett. 

This is a **one-time setup**. Once configured, the settings are saved as `.json` files in the `config/jackett/Jackett/Indexers/` folder, so they will automatically persist across fresh deployments.

**To add or change Indexers:**
1. Open the Jackett Web UI at `http://localhost:9117`.
2. Click the **"+ Add Indexer"** button at the top.
3. Search for your preferred trackers (e.g., *1337x*, *TorrentGalaxy*, *The Pirate Bay*) and click the **"+"** icon to add them.
4. *(Optional but recommended)* Test the indexers in the Jackett UI to ensure they are returning results.
5. In your terminal, commit the newly generated JSON files to Git:
   ```bash
   git add config/jackett/Jackett/Indexers/
   git commit -m "Add new Jackett indexers"
   ```

As long as these configuration files remain in the repository, any future `docker compose up` commands will automatically load these indexers into Jackett, and qBittorrent will be able to search them immediately.

---

## 🌐 Accessing qBittorrent from Other Devices (Local Network)

To access your qBittorrent Web UI from your phone, laptop, or tablet on the same WiFi/Local network:
1. Find the local IP address of the machine running Docker:
   - **Windows:** Run `ipconfig` in CMD or PowerShell (look for IPv4 Address, usually `192.168.x.x`).
   - **Linux/macOS:** Run `ifconfig` or `ip a` (look for `inet` under your main network adapter).
2. On your other device, open a web browser and go to `http://[LOCAL_IP_ADDRESS]:8080`.

---

## Accessing Anywhere via Tailscale

If you want to access your stack securely from anywhere in the world without exposing ports on your router, **[Tailscale](https://tailscale.com/)** is the easiest and most secure solution.

1. **Install Tailscale on the Host Machine:**
   Install Tailscale directly on the computer running Docker (Windows, macOS, or Linux). Do not run it in a container for this setup; host installation is much simpler and automatically proxies access to your exposed Docker ports.
2. **Authenticate and Connect:**
   Log in to Tailscale on the host machine and ensure it is connected.
3. **Find your Tailscale IP:**
   Tailscale assigns your machine a secure, static IP address (usually starting with `100.x.x.x`). You can find this in the Tailscale app or dashboard.
4. **Install Tailscale on your Client Devices:**
   Install the Tailscale app on your phone, laptop, or any device you want to use remotely.
5. **Access the Services:**
   While connected to Tailscale on your remote device (even if you are on cellular data or public WiFi), you can access your stack using the host machine's Tailscale IP:
   - qBittorrent: `http://[TAILSCALE_IP]:8080`
   - Jackett: `http://[TAILSCALE_IP]:9117`
