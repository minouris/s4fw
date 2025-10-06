#!/bin/bash

# Repository: https://github.com/minouris/s4fw
#
# Project: S4FW
# Author: Ciara Norrish (@minouris)
# License: MIT (see LICENSE.md)
#
# Description: Unpack all .zip files in ea_api/ into corresponding subfolders in ea_compiled/
#
# Revision: GIT_COMMIT_HASH


for zipfile in ea_api/*.zip; do
    foldername=$(basename "$zipfile" .zip)
    mkdir -p "ea_compiled/$foldername"
    unzip "$zipfile" -d "ea_compiled/$foldername"
done