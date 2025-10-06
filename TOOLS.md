# Tools for Sims 4 Modding

This folder contains tools for working with Sims 4 compiled Python files.

## Unpacking EA API Zip Files

You can unpack the official EA API zip files using the `unpack.sh` script or the provided VSCode tasks.

### Using the Command Line

Run the following command to unpack an EA API zip file (e.g., `sims4_api.zip`) into the `lib/ea_api` directory:

```sh
bash tools/unpack.sh
```

## Decompiling EA Scripts (and Mods)

You can decompile Sims 4 compiled Python files using the `decompile.sh` script or the provided VSCode tasks.

### Using the Command Line

Run the following command to decompile all scripts from the `ea_compiled` directory into `lib/ea`:

```sh
bash tools/decompile.sh --input-dir=ea_compiled --output-dir=lib/ea
```

Additional options:
- `--clean`: Remove the output directory before decompiling.
- `--trace`: Enable verbose tracing output.
- `--input-dir=<dir>`: Specify the directory containing compiled `.pyc` files to decompile.
- `--output-dir=<dir>`: Specify the directory where decompiled `.py` files will be written.
- `--in-file-list=<path>`: Only decompile files listed (one per line, absolute or relative path).
- `--base-path=<path>`: When using `--in-file-list`, remove this prefix from each input file path to determine its relative output location.
- `--logdir=<dir>`: Specify log directory for decompilation logs (default: logs).
- `--help`: Show usage information and exit.

#### Retrying Failed Decompiles

If any files fail to decompile, a `fail.log` will be created in the logs directory.  
You can retry decompiling only the failed files by passing the fail log as a file list:

```sh
bash tools/decompile.sh --input-dir=ea_compiled --output-dir=lib/ea --file-list=lib/ea/decompile_failures.txt
```

### Using VSCode Tasks

Several VSCode tasks are available for decompiling:

- **Decompile EA Scripts (Resume)**: Decompile without cleaning the output directory.
- **Decompile EA Scripts (Clean)**: Clean the output directory before decompiling.
- **Decompile EA Scripts (With Trace)**: Enable verbose tracing during decompilation.
- **Unpack EA API Zips**: Unpack the EA API zip file into the target directory.

To run a task:
1. Open the Command Palette (`Ctrl+Shift+P`).
2. Select `Tasks: Run Task`.
3. Choose the desired decompile task.

These tasks are defined in `.vscode/tasks.json` and use the `decompile.sh` script under the hood.


