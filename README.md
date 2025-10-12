# Sims 4 Modding Environment

## Requirements

- **WSL2** Windows Subsystem for Linux *(if on Windows)*
- **Docker** (with WSL2 integration if on Windows)
- **Visual Studio Code** (with Remote - Containers extension)
- **Python 3.7** (provided by the devcontainer)
- **Git**
- **The Sims 4** (installed on your system, for access to EA Python API files)
  - On **Linux**: Supported via **Steam** and/or **Proton** (see setup instructions below)
- **(Optional) GitHub CLI** (`gh`) for command-line forking
- **(Optional) unzip** for extracting the template zip

---

## Structure

- `src/`: Your mod code (to be included in releases)
- `build/`: The location that compiled code is built to when the `Build Mod` task is run
- `dist/`: The location that `.ts4script` are written to when the `Package Mod` task is run
- `mods/`: Mods run by Sims 4, and where packages are copied to by the `Deploy Mod` task
- `ea_api`: External mount (by Docker) of EA `Data/Simulation/Gameplay` folder for API zips
- `lib/external/`: External python libraries (for build/debug only, not for release)
- `lib/ea/`: Decompiled EA Python source (output from decompiling .pyc files)
- `ea_compiled/`: Compiled Python files from EA (unpacked by [tools/unpack.sh](tools/unpack.sh))
- `tools/`: Decompiler tool(s) for Sims 4 .pyc files

## Devcontainer
This project uses a devcontainer with Python 3.7 for compatibility with Sims 4 scripting.

## Setup Instructions

### Using This Repository as a Template

You can quickly start a new Sims 4 modding project by using this repository as a GitHub template:

1. **Create Your Own Repository**
   - Click the green "Use this template" button on the [GitHub repository page](https://github.com/minouris/s4fw).
   - Choose "Create a new repository" and fill in your desired repository name and settings.
   - Clone your new repository to your local machine:
     ```sh
     git clone https://github.com/<your-username>/<your-repo-name>.git
     cd <your-repo-name>
     ```

2. **Continue with Setup**
   - Follow the steps below to configure Docker, the devcontainer, and the EA API mount.

---

### Alternative: Manual Setup

If you do not wish to use the GitHub template feature, you can set up your project manually using one of the following methods:

#### 1. Download and Unzip from GitHub

1. Download a zip of this repository from the [GitHub page](https://github.com/minouris/s4fw) by clicking the green "Code" button and selecting "Download ZIP".
2. Unzip the downloaded file into your desired project directory.
3. Example:
  ```sh
  unzip s4fw-main.zip -d <your-new-project>
  cd <your-new-project>
  ```
4. Replace `<your-new-project>` with your desired project folder name.

#### 2. Fork on GitHub

**Option 1: Using the Browser**

1. Open the repository in your browser:
   ```sh
   $BROWSER https://github.com/minouris/s4fw.git
   ```
2. Click the "Fork" button in the top-right corner of the GitHub page.

3. **(Optional)** After forking, you can rename your forked repository on GitHub to anything you like (e.g., your mod's name) via the repository "Settings" page.

4. Copy the URL of your fork (e.g., `https://github.com/<your-username>/<your-repo-name>.git`).

5. Clone your fork:
   ```sh
   git clone https://github.com/<your-username>/<your-repo-name>.git <your-new-project>
   cd <your-new-project>
   ```

**Option 2: Command Line Only**

1. If you have the [GitHub CLI](https://cli.github.com/) installed, you can fork and clone in one step:
   ```sh
   gh repo fork minouris/s4fw --clone <your-new-project>
   cd <your-new-project>
   ```
   - After forking, you can rename your repository on GitHub using the browser if desired.
   - If you don't have `gh` installed, use the browser method above.

---

### Complete the Setup

#### 1. Install Prerequisites

- **[See detailed instructions for installing VSCode and Docker on Linux and WSL in `doc/REQUIREMENTS.md`](doc/REQUIREMENTS.md)**

#### 3. Configure Devcontainer and EA API Mount

You can use the provided setup scripts to automatically configure your environment, or edit the configuration manually.

**Recommended: Use the Setup Scripts**

- **On WSL2 (Windows):**
  - Use the setup script to detect your Sims 4 installation and patch your devcontainer:
    ```sh
    setup/setup.sh
    ```
    This script will:
    - Attempt to automatically locate your Sims 4 installation directory on Windows
    - Update your `.devcontainer/devcontainer.json` to mount the correct EA API folder into the devcontainer
    - Prompt you to enter or confirm mod metadata (such as mod name, author, and description)
    - Create or update your `mod_info.json` file with the provided information

- **On Linux (Steam/Proton):**
  - Use the setup script to detect your Sims 4 installation and patch your devcontainer:
    ```sh
    setup/setup_linux_proton.sh
    ```
    This script will:
    - Attempt to automatically locate your Sims 4 installation directory under your Steam library (including Proton prefixes if used)
    - Update your `.devcontainer/devcontainer.json` to mount the correct EA API folder into the devcontainer
    - Prompt you to enter or confirm mod metadata (such as mod name, author, and description)
    - Create or update your `mod_info.json` file with the provided information

**Manual Setup (Alternative):**

- **On WSL2 (Windows):**
  - In your `.devcontainer/devcontainer.json`, locate the following section (this is how it appears by default):
    ```json
    "mounts": [
      "source=__SIMS4_EA_ZIPS_PATH__,target=/workspaces/s4fw/ea_api,type=bind,readonly",
      "source=__SIMS4_MODS_PATH__,target=/workspaces/s4fw/mods,type=bind",
      "source=/etc/timezone,target=/etc/timezone,type=bind,readonly",
      "source=/etc/localtime,target=/etc/localtime,type=bind,readonly"
    ]
    ```
  - **Replace** the `__SIMS4_EA_ZIPS_PATH__` and `__SIMS4_MODS_PATH__` placeholders with the actual paths to your Sims 4 EA API folder and Mods folder. Do not add new mounts—just replace the variables in the existing lines.
    - `__SIMS4_EA_ZIPS_PATH__`: Path to your Sims 4 EA API folder (e.g., `/mnt/c/Program Files/EA Games/The Sims 4/Data/Simulation/Gameplay`)
    - `__SIMS4_MODS_PATH__`: Path to your Sims 4 Mods folder (e.g., `/mnt/c/Users/<your-windows-username>/Documents/Electronic Arts/The Sims 4/Mods`)
  - **Example after replacing:**
    ```json
    "mounts": [
      "source=/mnt/c/Program Files/EA Games/The Sims 4/Data/Simulation/Gameplay,target=/workspaces/s4fw/ea_api,type=bind,readonly",
      "source=/mnt/c/Users/<your-windows-username>/Documents/Electronic Arts/The Sims 4/Mods,target=/workspaces/s4fw/mods,type=bind",
      "source=/etc/timezone,target=/etc/timezone,type=bind,readonly",
      "source=/etc/localtime,target=/etc/localtime,type=bind,readonly"
    ]
    ```
    - Replace `<your-windows-username>` with your actual Windows username.
    - Use forward slashes and WSL/Unix format for all paths.

- **On Linux (Steam/Proton):**
  - In your `.devcontainer/devcontainer.json`, the original section is the same:
    ```json
    "mounts": [
      "source=__SIMS4_EA_ZIPS_PATH__,target=/workspaces/s4fw/ea_api,type=bind,readonly",
      "source=__SIMS4_MODS_PATH__,target=/workspaces/s4fw/mods,type=bind",
      "source=/etc/timezone,target=/etc/timezone,type=bind,readonly",
      "source=/etc/localtime,target=/etc/localtime,type=bind,readonly"
    ]
    ```
  - **Replace** the placeholders as follows:
    - `__SIMS4_EA_ZIPS_PATH__`: Path to your Sims 4 EA API folder (e.g., `/home/<your-username>/.steam/steam/steamapps/common/The Sims 4/Data/Simulation/Gameplay`)
    - `__SIMS4_MODS_PATH__`: Path to your Sims 4 Mods folder (e.g., `/home/<your-username>/.local/share/Steam/steamapps/compatdata/<proton-app-id>/pfx/drive_c/users/steamuser/Documents/Electronic Arts/The Sims 4/Mods`)
  - **Example after replacing:**
    ```json
    "mounts": [
      "source=/home/<your-username>/.steam/steam/steamapps/common/The Sims 4/Data/Simulation/Gameplay,target=/workspaces/s4fw/ea_api,type=bind,readonly",
      "source=/home/<your-username>/.local/share/Steam/steamapps/compatdata/<proton-app-id>/pfx/drive_c/users/steamuser/Documents/Electronic Arts/The Sims 4/Mods,target=/workspaces/s4fw/mods,type=bind",
      "source=/etc/timezone,target=/etc/timezone,type=bind,readonly",
      "source=/etc/localtime,target=/etc/localtime,type=bind,readonly"
    ]
    ```
    - Replace `<your-username>` and `<proton-app-id>` as appropriate.
    - If you run Sims 4 natively, use your home Documents path instead for the Mods folder

---

## Next Steps: Open the Devcontainer and Prepare Your Modding Environment

### 1. Open the Devcontainer

- Open the project folder in Visual Studio Code.
- If prompted, click "Reopen in Container" (or use the Command Palette: `Remote-Containers: Reopen in Container`).
- Wait for the devcontainer to build and initialize.

*End result: Your development environment is set up with all required tools and paths.*

### 2. Unpack the EA API Zips

You must extract the EA `.pyc` files from the official zips before decompiling.

**Using VSCode Task:**
- Open the Command Palette (`Ctrl+Shift+P`), select `Tasks: Run Task`, and choose **Unpack EA API Zips**.

**Or using the command line:**
```sh
bash tools/unpack.sh
```

*End result: EA `.pyc` files are extracted into the `ea_compiled/` directory.*

### 3. Decompile the EA Python Sources

Decompile the `.pyc` files to `.py` sources.

**Using VSCode Task:**
- Open the Command Palette (`Ctrl+Shift+P`), select `Tasks: Run Task`, and choose one of:
  - **Decompile EA Scripts (Resume)** (recommended for most cases)
  - **Decompile EA Scripts (Clean)** (removes previous output first)
  - **Decompile EA Scripts (With Trace)** (for verbose output)

**Or using the command line:**
```sh
bash tools/decompile.sh --input-dir=ea_compiled --output-dir=lib/ea
```

*End result: Decompiled EA Python source files are available in the `lib/ea/` directory.*

### 4. Build Your Mod

Compile your mod source code from `src/` into the `build/` directory.

**Using VSCode Task:**
- Open the Command Palette, select `Tasks: Run Task`, and choose **Build Mod**.

**Or using the command line:**
```sh
bash tools/build.sh
```

*End result: Your mod's compiled files are placed in the `build/` directory.*

### 5. Package Your Mod

Package your built mod files into a `.ts4script` archive in the `dist/` directory.

**Using VSCode Task:**
- Open the Command Palette, select `Tasks: Run Task`, and choose **Package Mod**.

**Or using the command line:**
```sh
bash tools/package.sh
```

*End result: Your packaged `.ts4script` mod file is created in the `dist/` directory.*

### 6. Deploy Your Mod

Copy your packaged mod into your Sims 4 Mods folder.

**Using VSCode Task:**
- Open the Command Palette, select `Tasks: Run Task`, and choose **Deploy Mod**.
- Or use **Build + Package + Deploy** to run all steps in sequence.

**Or using the command line:**
```sh
bash tools/deploy.sh
```

*End result: Your packaged mod is copied to the `mods/` directory (linked to your Sims 4 Mods folder).*

---

For more details on available tools and options, see [TOOLS.md](TOOLS.md).

**You are now ready to start modding The Sims 4!**

