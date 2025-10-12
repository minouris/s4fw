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

#### 1. Install Docker

- **On WSL2 (Windows):**
  - Ensure Docker is installed and running inside your WSL environment. Follow the official Docker documentation for [Docker Desktop on WSL](https://docs.docker.com/desktop/wsl/) or install Docker Engine directly in your WSL distribution.

- **On Linux (Native):**
  - Install Docker using your distribution's package manager or follow the [official Docker Engine instructions](https://docs.docker.com/engine/install/).

#### 2. Configure Devcontainer and EA API Mount

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
  - Edit your devcontainer configuration ([.devcontainer/devcontainer.json]) to add a mount for the EA Python API zips:
    ```json
    "mounts": [
      "source=/mnt/c/Program Files/EA Games/The Sims 4/Data/Simulation/Gameplay/,target=/workspaces/s4fw/ea_api,type=bind,consistency=cached"
    ]
    ```
  - Adjust the `source` path to match the location where the EA API zips live on your system. **MUST** be a unix path - do not use `C:\Program Files\EA Games\...`

- **On Linux (Steam/Proton):**
  1. **Locate The Sims 4 Game Files**
     - The Sims 4 is typically installed under your Steam library, e.g.:
       ```
       ~/.steam/steam/steamapps/common/The Sims 4/
       ```
     - The EA Python API zips are found in:
       ```
       ~/.steam/steam/steamapps/common/The Sims 4/Data/Simulation/Gameplay/
       ```
     - Adjust the path as needed if your Steam library is elsewhere.

  2. **Devcontainer Volume Mount**
     - Edit your devcontainer configuration to add a mount for the EA API zips:
       ```json
       "mounts": [
         "source=/home/<your-username>/.steam/steam/steamapps/common/The Sims 4/Data/Simulation/Gameplay/,target=/workspaces/s4fw/ea_api,type=bind,consistency=cached"
       ]
       ```
     - Replace `<your-username>` with your Linux username.

  3. **Proton Prefix Caveat**
     - If you use a custom Steam library or Proton prefix, adjust the path accordingly.

#### 3. Open the Devcontainer

- Open the project in VSCode and reopen in the container.

#### 4. Unpack and Decompile EA API Files

You can use the provided VSCode tasks to automate unpacking and decompiling, or run the equivalent commands manually in the terminal.

**To run VSCode tasks:**
- Open the Command Palette (`Ctrl+Shift+P` or `F1`).
- Type and select `Tasks: Run Task`.
- Choose one of the following tasks:
  - **Unpack EA API**: Extracts the necessary `.pyc` files from the EA API zips in `ea_api/` into the `ea_compiled/` directory.
  - **Decompile EA API (Clean)**: Decompiles `.pyc` files from `ea_compiled/` into Python source files in `lib/ea/`.

**To run these steps manually:**

- **Unpack API files:**
  ```sh
  ./tools/unpack.sh
  ```
  This script extracts the required `.pyc` files from the EA API zips into `ea_compiled/`.

- **Decompile API files:**
  ```sh
  ./tools/decompile.sh --input-dir=ea_compiled --output-dir=lib/ea --clean
  ```
  This script decompiles the `.pyc` files in `ea_compiled/` and writes the resulting `.py` files to `lib/ea/`.

You can also inspect or modify the available tasks in `.vscode/tasks.json`.

### Additional Decompile Tasks

- **Decompile EA Scripts (Resume):**  
  Runs `tools/decompile.sh` to decompile `.pyc` files from `ea_compiled/` to `lib/ea/` without cleaning the output directory first. Useful for resuming or incremental decompilation.

- **Decompile EA Scripts (Clean):**  
  Runs `tools/decompile.sh` with `--clean` to remove existing files in `lib/ea/` before decompiling. Ensures a fresh decompile.

- **Decompile EA Scripts (With Trace):**  
  Runs `tools/decompile.sh` with `--trace` for verbose output during decompilation. Useful for debugging decompilation issues.

### See `TOOLS.md` for Details

For more detailed instructions and troubleshooting, refer to [TOOLS.md](TOOLS.md).

## Keeping Your Project Up to Date

If you want to pull in updates from this template repository after you've started your own project, you can add the original repo as an "upstream" remote and merge changes:

1. **Add Upstream Remote**
   ```sh
   git remote add upstream https://github.com/minouris/s4fw.git
   ```

2. **Fetch and Merge Updates**
   ```sh
   git fetch upstream
   git merge upstream/main
   ```
   - Resolve any merge conflicts if prompted.
   - Push the merged changes to your own repository:
     ```sh
     git push origin main
     ```

See [GitHub documentation on syncing forks](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/syncing-a-fork) for more details.

## License

See [LICENSE](LICENSE) for license information.

## Attribution

- Sims 4 and related assets are © Electronic Arts Inc. This project is not affiliated with or endorsed by Electronic Arts.
- This project uses tools by third party authors - please see [ATTRIBUTION.md](ATTRIBUTION.md) for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a history of changes to this project.

