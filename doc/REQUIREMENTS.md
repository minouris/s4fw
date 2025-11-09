# Installing Prerequisites: VSCode and Docker

This guide covers installing **Visual Studio Code** and **Docker** on:

- Ubuntu Linux (native)
- Ubuntu under Windows Subsystem for Linux (WSL2)

---

## Ubuntu Linux (Native)

### 1. Install Visual Studio Code

```sh
sudo apt update
sudo apt install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code
```

Or, download the `.deb` from [https://code.visualstudio.com/](https://code.visualstudio.com/) and install via:

```sh
sudo apt install ./<file>.deb
```

### 2. Install Docker Engine

```sh
sudo apt update
sudo apt install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
```

- Add your user to the `docker` group (optional, allows running Docker without `sudo`):

```sh
sudo usermod -aG docker $USER
# Log out and back in for group change to take effect
```

### 3. (Optional) Install Docker Compose

```sh
sudo apt install docker-compose-plugin
```

---

## Ubuntu under WSL2 (Windows Subsystem for Linux)

### 1. Install Visual Studio Code

- **On Windows:**  
  Download and install VSCode from [https://code.visualstudio.com/](https://code.visualstudio.com/).
- **In WSL (Ubuntu):**  
  No need to install VSCode inside WSL; use the Windows install and the "Remote - WSL" extension.

### 2. Install Docker

- **Preferred:**  
  Install Docker Engine directly inside your WSL2 Ubuntu environment.  
  Follow the [official Docker Engine for Ubuntu instructions](https://docs.docker.com/engine/install/ubuntu/).

- **Alternative:**  
  If you already use [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/):
  - Enable "Use the WSL 2 based engine" in Docker Desktop settings.
  - Enable integration with your WSL2 Ubuntu distribution.

- **Note:**  
  Do **not** install both Docker Desktop and Docker Engine in WSL at the same time. Use one or the other.

### 3. (Optional) Install Docker Compose

- If you installed Docker Engine in WSL, follow the Linux instructions above.
- If you use Docker Desktop, Docker Compose is included.

---

## After Installation

- **Verify Docker:**  
  Run `docker --version` and `docker run hello-world` to check Docker is working.
- **Verify VSCode:**  
  Launch VSCode and install the "Remote - Containers" extension (and "Remote - WSL" if using WSL).

---
