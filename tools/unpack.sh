#!/bin/bash

for zipfile in ea_api/*.zip; do
    foldername=$(basename "$zipfile" .zip)
    mkdir -p "ea_compiled/$foldername"
    unzip "$zipfile" -d "ea_compiled/$foldername"
done