# Tools for Sims 4 Modding

This folder contains tools for working with Sims 4 compiled Python files.

## Recommended Decompiler: unpyc3
- unpyc3 is a Python 3.7+ decompiler that works well for Sims 4 .pyc files.
- Project: https://github.com/rocky/python-uncompyle6 (uncompyle6) or https://github.com/andrew-tavera/unpyc3 (unpyc3)

## Usage
You can install unpyc3 in your devcontainer:

```bash
pip install unpyc3
```

Or clone the repo into this folder for local use:

```bash
git clone https://github.com/andrew-tavera/unpyc3.git
```

Then run the decompiler on a .pyc file:

```bash
python -m unpyc3 <path-to-file.pyc> -o ../lib/ea
```
