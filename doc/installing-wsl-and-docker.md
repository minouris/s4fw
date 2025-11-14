# Installing VSCode, WSL2, Ubuntu, and Docker: A Complete Guide

This guide will walk you through setting up a complete development environment on Windows. By the end, you'll have Visual Studio Code, Windows Subsystem for Linux (WSL2) with Ubuntu, and Docker Engine running smoothly.

---

## What You're Installing

- **Visual Studio Code (VSCode)**: A powerful code editor
- **WSL2**: A feature that lets you run Linux directly on Windows
- **Ubuntu**: A popular Linux distribution that runs inside WSL2
- **Docker Engine**: A tool for running containerized applications

---

## Part 1: Install Visual Studio Code

VSCode is your code editor and will run on Windows.

1. **Download VSCode:**
   - Go to [https://code.visualstudio.com/](https://code.visualstudio.com/)
   - Download the Windows installer
   - Run the downloaded installer (`.exe` file)

2. **Install with default options:**
   - Accept the license agreement
   - Keep the default installation location
   - **Important:** Check the box "Add to PATH" if prompted
   - Complete the installation

3. **Launch VSCode** to verify it works

---

## Part 2: Enable WSL2 on Windows

WSL2 lets you run Linux on Windows without a virtual machine.

### Step 1: Open PowerShell as Administrator

1. Press the **Windows key** on your keyboard
2. Type `powershell`
3. Right-click on "Windows PowerShell"
4. Select **"Run as administrator"**
5. Click "Yes" when prompted

### Step 2: Enable WSL

In the PowerShell window, type or paste this command and press Enter:

```powershell
PS C:\> wsl --install
```

This single command will:
- Enable WSL
- Enable the Virtual Machine Platform
- Install the latest Linux kernel
- Set WSL2 as the default version
- Install Ubuntu (the default Linux distribution)

### Step 3: Restart Your Computer

After the command completes, restart your computer. This is required for WSL to work properly.

---

## Part 3: Complete Ubuntu Setup

After restarting, Ubuntu will automatically launch (a terminal window will open).

1. **Wait for Ubuntu to finish installing** (this takes a few minutes)

2. **Create your Linux user account:**
   - You'll be asked: `Enter new UNIX username:`
   - Type a username (lowercase, no spaces) and press Enter
   - Type a password and press Enter (you won't see characters as you type - this is normal)
   - Retype the password and press Enter

   > **Important:** This password is for Ubuntu, not Windows. Remember it - you'll need it when installing software in Linux.

### Understanding the Bash Prompt

You'll notice the terminal shows something like `user@machine:~$` before each command. This is the bash prompt, and it tells you:

- `user` - Your username in Ubuntu
- `@` - Just a separator
- `machine` - Your computer's hostname
- `~` - Your current directory (`~` is shorthand for your home directory: `/home/user`)
- `$` - Indicates you're a regular user (if you see `#`, you're running as root/admin)

When you see this prompt, Ubuntu is ready for you to type a command. In this guide, we show `user@machine:~$` in code examples, but your actual prompt will show your real username and machine name.

3. **Update Ubuntu** (this ensures you have the latest software):
   
   Type these commands one at a time and press Enter after each:

   ```bash
   user@machine:~$ sudo apt update
   ```
   
   (Enter your Ubuntu password when prompted)
   
   ```bash
   user@machine:~$ sudo apt upgrade -y
   ```

   This might take several minutes. Wait for it to complete.

   > **About these commands:**
   > - `sudo` means "superuser do" - it runs the command with administrator privileges. You'll need to enter your Ubuntu password.
   > - `apt` is Ubuntu's package manager - it installs, updates, and removes software.
   > - `apt update` refreshes the list of available software.
   > - `apt upgrade` installs updates for software you already have.

---

## Part 4: Install Docker Engine in WSL

Now you'll install Docker directly in your Ubuntu environment. 

> **If you already have Docker Desktop:** Docker Desktop and Docker Engine shouldn't run at the same time. You have two options:
> - **Option A:** Uninstall Docker Desktop and use Docker Engine in WSL (recommended for this workflow)
> - **Option B:** Keep Docker Desktop and skip this section, but enable WSL2 integration in Docker Desktop settings

### Installing Docker Engine (following official Docker documentation)

Make sure you're in your Ubuntu terminal. If you closed it, you can open it by:
- Press Windows key, type `ubuntu`, and click on "Ubuntu"

Now run these commands:

#### 1. Remove old Docker versions (if any):

```bash
user@machine:~$ sudo apt-get remove docker docker-engine docker.io containerd runc
```

(It's okay if it says these packages aren't installed)

#### 2. Set up Docker's repository:

```bash
user@machine:~$ sudo apt-get update
user@machine:~$ sudo apt-get install ca-certificates curl
```

```bash
user@machine:~$ sudo install -m 0755 -d /etc/apt/keyrings
```

```bash
user@machine:~$ sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
```

```bash
user@machine:~$ sudo chmod a+r /etc/apt/keyrings/docker.asc
```

#### 3. Add Docker repository to your sources:

```bash
user@machine:~$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

#### 4. Install Docker Engine:

```bash
user@machine:~$ sudo apt-get update
```

```bash
user@machine:~$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

When asked "Do you want to continue? [Y/n]", type `y` and press Enter.

#### 5. Add yourself to the docker group (so you don't need to type `sudo` every time):

```bash
user@machine:~$ sudo usermod -aG docker $USER
```

#### 6. Start Docker:

```bash
user@machine:~$ sudo service docker start
```

> **Note:** If Docker commands don't work later, you may need to start the Docker service with `sudo service docker start`. Some WSL setups start it automatically, others don't.

---

## Part 5: Set Up VSCode for WSL

Now connect VSCode to your WSL environment.

### Install the WSL Extension

1. **Open VSCode** on Windows
2. Click the Extensions icon on the left sidebar (it looks like four squares)
3. Search for `WSL`
4. Find "WSL" by Microsoft and click **Install**
5. Also search for and install "Remote - Containers" (also called "Dev Containers")

### Connect to WSL

1. In VSCode, press `Ctrl+Shift+P` to open the command palette
2. Type `WSL: Connect to WSL` and select it
3. A new VSCode window opens - this is now running inside Ubuntu!

You can verify you're in WSL by looking at the bottom-left corner of VSCode. It should show a green indicator saying `WSL: Ubuntu`.

> **Accessing Windows Files from WSL:**
> If you have a project in Windows (like `C:\Users\YourName\Documents\my-project`), the easiest way to open it in WSL is:
> 1. In VSCode (Windows), open that folder normally
> 2. Press `Ctrl+Shift+P` and select "WSL: Reopen Folder in WSL"
> 
> VSCode will automatically handle accessing your Windows files through WSL. However, for best performance with Docker and Linux tools, consider moving or cloning your project into your Linux home directory (`/home/yourusername/`).

---

## Part 6: Verify Everything Works

Let's make sure everything is installed correctly.

### Test Docker

1. In VSCode, open a terminal: **Terminal → New Terminal** (or press `` Ctrl+` ``)
2. This terminal is now a Linux bash terminal (not PowerShell!)
3. Check Docker version:

   ```bash
   user@machine:~$ docker --version
   ```

   You should see something like `Docker version 24.x.x`

4. Run the hello-world test:

   ```bash
   user@machine:~$ docker run hello-world
   ```

   You should see a message saying "Hello from Docker!"

### Test Your Setup

In the same terminal:

```bash
# Check you're in Linux
user@machine:~$ uname -a

# Check Docker Compose
user@machine:~$ docker compose version
```

---

## Part 7: Getting Started with This Project

You now have a complete development environment! Here's how to get started with this Sims 4 modding project:

1. **Get the project:**
   - If using the template: Click "Use this template" on GitHub, clone your new repository
   - If forking: Fork the repository on GitHub and clone your fork
   - See the main [README.md](../README.md) for detailed instructions

2. **Open the project in WSL:**
   - In VSCode (Windows), open your cloned project folder
   - Press `Ctrl+Shift+P` and select "WSL: Reopen Folder in WSL"
   - Or if you cloned the project in Ubuntu, open a terminal, navigate to the project folder, and run:
     ```bash
     user@machine:~/your-project$ code .
     ```

3. **Configure the project:**
   - Run the setup script to automatically configure your devcontainer:
     ```bash
     user@machine:~/your-project$ bash setup/setup.sh
     ```
   - This will detect your Sims 4 installation and set up the necessary mounts

4. **Open in container:**
   - VSCode will prompt you to "Reopen in Container" - click it
   - Or use Command Palette: `Remote-Containers: Reopen in Container`
   - Wait for the devcontainer to build

5. **Start modding:**
   - Follow the "Next Steps" section in the main [README.md](../README.md) to:
     - Unpack EA API zips
     - Decompile EA Python sources
     - Build, package, and deploy your mod

For complete project setup and modding workflow details, refer to the [README.md](../README.md).

---

## Quick Reference

### Opening Ubuntu Terminal

- **From Windows:** Press Windows key, type `ubuntu`, press Enter
- **From VSCode:** Terminal → New Terminal (when connected to WSL)

### If Docker Commands Don't Work

If you get "Cannot connect to the Docker daemon", start the service:

```bash
user@machine:~$ sudo service docker start
```

### Common Commands

**Navigation and files:**
```bash
user@machine:~$ pwd                    # Show current directory
user@machine:~$ ls                     # List files
user@machine:~$ cd foldername          # Change directory
user@machine:~$ cd ~                   # Go to home directory
user@machine:~$ cd ..                  # Go up one directory
```

**Working with the system:**
```bash
user@machine:~$ sudo apt update        # Update package lists
user@machine:~$ sudo apt upgrade       # Upgrade installed packages
user@machine:~$ sudo apt install pkg   # Install a package
```

**Docker commands:**
```bash
user@machine:~$ docker ps              # List running containers
user@machine:~$ docker images          # List downloaded images
user@machine:~$ docker --version       # Check Docker version
```

**Git commands:**
```bash
user@machine:~$ git clone <url>        # Clone a repository
user@machine:~$ git status             # Check repository status
user@machine:~$ git add .              # Stage all changes
user@machine:~$ git commit -m "msg"    # Commit with message
user@machine:~$ git push               # Push changes to remote
user@machine:~$ git pull               # Pull changes from remote
```

### Switching Between Windows and Linux Files

**Accessing Windows from Linux (WSL):**

Your Windows drives are automatically mounted under `/mnt/`:

```bash
# Your C: drive (C:\)
user@machine:~$ cd /mnt/c/

# Your Windows user folder (C:\Users\YourWindowsUsername\)
user@machine:~$ cd /mnt/c/Users/YourWindowsUsername/

# Program Files (C:\Program Files\)
user@machine:~$ cd /mnt/c/Program\ Files/
# or use quotes for spaces:
user@machine:~$ cd "/mnt/c/Program Files/"

# Other drives (D:\, E:\, etc.)
user@machine:~$ cd /mnt/d/
```

**Accessing Linux from Windows:**

Your Ubuntu files are accessible from Windows Explorer at:
```
\\wsl$\Ubuntu\home\yourusername\
```

Or type `\\wsl$\Ubuntu` in the Windows Explorer address bar to browse your Linux filesystem.

> **Best practice:** Keep your projects in the Linux filesystem (`/home/yourusername/`) for better performance with Docker and Linux tools.

**Want to learn more about bash?** Check out this beginner-friendly tutorial: [Ryan's Tutorials - Linux Tutorial](https://ryanstutorials.net/linuxtutorial/)

---

## Troubleshooting

### "WSL 2 requires an update to its kernel component"

1. Download the update from: [https://aka.ms/wsl2kernel](https://aka.ms/wsl2kernel)
2. Install it
3. Restart the WSL installation

### Docker commands say "Cannot connect to the Docker daemon"

Run: `sudo service docker start`

### "Permission denied while trying to connect to the Docker daemon socket"

Run: `sudo usermod -aG docker $USER`

Then close and reopen your terminal.

### Ubuntu terminal closes immediately after opening

Open PowerShell as admin and run:

```powershell
PS C:\> wsl --set-default-version 2
```

### VSCode can't find Docker

Make sure:
1. You've installed the "Remote - Containers" extension
2. You're connected to WSL (green indicator bottom-left should say "WSL: Ubuntu")
3. Docker is running: `sudo service docker start`

---

## Understanding Your New Environment

### Two Worlds: Windows and Linux

You now have two operating systems working together:

- **Windows:** Where VSCode runs, your normal files live
- **Linux (Ubuntu via WSL):** Where Docker and development tools run

VSCode bridges these two worlds seamlessly.

### The Terminal

When you open a terminal in VSCode (while connected to WSL), you're using **bash** - the Linux command line. This is different from PowerShell:

- **PowerShell commands** (Windows): `dir`, `cd`, `copy`
- **Bash commands** (Linux): `ls`, `cd`, `cp`

The terminal prompt will help you know where you are:
- In Linux: `username@computername:~$`
- In PowerShell: `PS C:\Users\YourName>`

### File Paths

- **Windows style:** `C:\Users\YourName\Documents`
- **Linux style:** `/home/yourusername/documents`

In WSL, you can access Windows files at `/mnt/c/`, but it's faster to keep projects in the Linux filesystem.

---

## Additional Resources

- [Official WSL Documentation](https://learn.microsoft.com/en-us/windows/wsl/)
- [Docker Engine Ubuntu Installation](https://docs.docker.com/engine/install/ubuntu/)
- [VSCode WSL Documentation](https://code.visualstudio.com/docs/remote/wsl)

---

**Congratulations!** You've set up a professional development environment. Welcome to the world of Linux development on Windows!
