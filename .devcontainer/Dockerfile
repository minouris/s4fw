FROM python:3.7-slim

# Install any build dependencies here
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install unpyc3 for decompiling Sims 4 .pyc files
RUN pip install unpyc3

WORKDIR /workspace
