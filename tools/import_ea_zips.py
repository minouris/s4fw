import json
import os
import shutil
import zipfile

CONFIG_PATH = os.path.join(os.path.dirname(__file__), '..', 's4fw_config.json')
EA_COMPILED_DIR = os.path.join(os.path.dirname(__file__), '..', 'ea_compiled')

with open(CONFIG_PATH, 'r') as f:
    config = json.load(f)

zips_path = config.get('ea_zips_path')
if not zips_path or not os.path.isdir(zips_path):
    raise RuntimeError(f"EA zips path not found or invalid: {zips_path}")

for zip_name in ["base.zip", "core.zip", "simulation.zip"]:
    zip_file = os.path.join(zips_path, zip_name)
    if not os.path.isfile(zip_file):
        print(f"Warning: {zip_file} not found.")
        continue
    with zipfile.ZipFile(zip_file, 'r') as z:
        for member in z.namelist():
            if member.endswith('.pyc'):
                out_path = os.path.join(EA_COMPILED_DIR, member)
                os.makedirs(os.path.dirname(out_path), exist_ok=True)
                with open(out_path, 'wb') as out_f:
                    out_f.write(z.read(member))
                print(f"Extracted {member} to {out_path}")
