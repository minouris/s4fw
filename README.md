# Sims 4 Modding Environment

- `src/`: Your mod code (to be included in releases)
- `lib/external/`: External libraries from GitHub (for build/debug only, not for release)
- `lib/ea/`: Decompiled EA Python source (output from decompiling .pyc files)
- `ea_compiled/`: Compiled Python files from EA
- `tools/`: Decompiler tool(s) for Sims 4 .pyc files

## Devcontainer
This project uses a devcontainer with Python 3.7 for compatibility with Sims 4 scripting.

## Setup Instructions

1. **Unzip This Template**
   - Unzip the provided zip file into your desired project directory.
   - Example:
     ```sh
     unzip s4fw.zip -d <your-new-project>
     cd <your-new-project>
     ```
   - Replace `<your-new-project>` with your desired project folder name.

   **Alternatively, Fork on GitHub**
   - If you prefer to start from the git repository, fork it to your own GitHub account. You can do this via the browser or the command line:

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

2. **Install Docker in WSL**
   - Ensure Docker is installed and running inside your WSL environment. Follow the official Docker documentation for [Docker Desktop on WSL](https://docs.docker.com/desktop/wsl/) or install Docker Engine directly in your WSL distribution.

3. **Edit Devcontainer Volume Mount**
   - Before opening the container, edit your devcontainer configuration ([.devcontainer/devcontainer.json](`.devcontainer/devcontainer.json`)) to edit the volume mount for the EA Python API zips.
   - Example:
     ```json
     "mounts": [
       "source=/mnt/c/Program Files/EA Games/The Sims 4/Data/Simulation/Gameplay/,target=/workspaces/s4fw/ea_api,type=bind,consistency=cached"
     ]
     ```
   - Adjust the `source` path to match the location where the EA API zips live on your system. **MUST** be a unix path - do not use `C:\Program Files\EA Games\...`

4. **Open the Devcontainer**
   - Open the project in VSCode and reopen in the container.

5. **Unpack and Decompile EA API Files**
   - Use the provided VSCode tasks (see `tasks.json`) or run the equivalent commands in the terminal:
     - **Unpack API files:** Run the "Unpack EA API" task to extract the necessary files from the game directory into `ea_compiled/`.
     - **Decompile:** Run the "Decompile EA API" task to convert `.pyc` files in `ea_compiled/` into Python source in `lib/ea/`.

6. **See `TOOLS.md` for Details**
   - For more detailed instructions and troubleshooting, refer to [TOOLS.md](TOOLS.md).
   - For more detailed instructions and troubleshooting, refer to [TOOLS.md](TOOLS.md).
5. **Unpack and Decompile EA API Files**
   - Use the provided VSCode tasks (see `tasks.json`) or run the equivalent commands in the terminal:
     - **Unpack API files:** Run the "Unpack EA API" task to extract the necessary files from the game directory into `ea_compiled/`.
     - **Decompile:** Run the "Decompile EA API" task to convert `.pyc` files in `ea_compiled/` into Python source in `lib/ea/`.

6. **See `TOOLS.md` for Details**
   - For more detailed instructions and troubleshooting, refer to [TOOLS.md](TOOLS.md).
   - For more detailed instructions and troubleshooting, refer to [TOOLS.md](TOOLS.md).
