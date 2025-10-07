# Sims 4 Modding Environment

## Requirements

- **WSL2** Windows Subsystem for Linux
- **Docker** (with WSL2 integration if on Windows)
- **Visual Studio Code** (with Remote - Containers extension)
- **Python 3.7** (provided by the devcontainer)
- **Git**
- **The Sims 4** (installed on your system, for access to EA Python API files)
- **(Optional) GitHub CLI** (`gh`) for command-line forking
- **(Optional) unzip** for extracting the template zip

## Structure

- `src/`: Your mod code (to be included in releases)
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

   - Download a zip of this repository from the [GitHub page](https://github.com/minouris/s4fw) by clicking the green "Code" button and selecting "Download ZIP".
   - Unzip the downloaded file into your desired project directory.
   - Example:
     ```sh
     unzip s4fw-main.zip -d <your-new-project>
     cd <your-new-project>
     ```
   - Replace `<your-new-project>` with your desired project folder name.

#### 2. Unzip This Template
   - Unzip the provided zip file into your desired project directory.
   - Example:
     ```sh
     unzip s4fw.zip -d <your-new-project>
     cd <your-new-project>
     ```
   - Replace `<your-new-project>` with your desired project folder name.

#### 3. Fork on GitHub

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

2. **Install Docker in WSL**
   - Ensure Docker is installed and running inside your WSL environment. Follow the official Docker documentation for [Docker Desktop on WSL](https://docs.docker.com/desktop/wsl/) or install Docker Engine directly in your WSL distribution.

3. **Run Setup Script**
   - Before opening the container, run the setup script to configure the devcontainer and volume mount for the EA Python API zips:
     ```sh
     ./setup/setup.sh
     ```
   - The script will prompt you for:
     - The drive letter where your **Documents** folder is located (e.g., `c`, `d`, `e`)
     - Your Sims 4 **game launcher** (EA App, Origin, Steam, Epic Games, or Other)
     - The drive letter or path where your **game installation** is located (if not detected automatically)
   - It will update the devcontainer configuration with the correct paths for your system.

4. **Open the Devcontainer**
   - Open the project in VSCode and reopen in the container.

5. **Unpack and Decompile EA API Files**
   - Use the provided VSCode tasks (see `tasks.json`) or run the equivalent commands in the terminal:
     - **Unpack API files:** Run the "Unpack EA API" task to extract the necessary files from the game directory into `ea_compiled/`.
     - **Decompile:** Run the "Decompile EA API" task to convert `.pyc` files in `ea_compiled/` into Python source in `lib/ea/`.

6. **See `TOOLS.md` for Details**
   - For more detailed instructions and troubleshooting, refer to [TOOLS.md](TOOLS.md).

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

