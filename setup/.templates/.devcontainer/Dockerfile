# Repository: https://github.com/minouris/s4fw
#
# Project: S4FW
# Author: Ciara Norrish (@minouris)
# License: MIT (see LICENSE.md)
#
# Description: Dev container for Sims 4 Framework development

FROM python:3.7.9-slim-buster

# Prevent interactive prompts during package installation and set default TZ
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Buster is archived; point apt sources to the archive mirrors and disable
# the 'Valid-Until' check so apt can use older Release files.
RUN sed -i 's|deb.debian.org|archive.debian.org|g; s|security.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until \
 && apt-get update -o Acquire::Check-Valid-Until=false \
 && apt-get install -y --no-install-recommends \
    build-essential \
    sudo \
    tzdata \
    git \
    curl \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m pip install "pytest==6.2.5" typing_extensions && \
    python -m pip install "pytest-cov==2.12.1"

# Set fallback timezone (will be overridden by host mount if available)
ENV TZ=UTC

# Install uncompypython decompilers for decompiling Sims 4 .pyc files
RUN pip install uncompyle6 decompyle3
RUN git clone https://github.com/andrews4s/unpyc37.git /opt/unpyc37

# Create a non-root user 'sims4fw' with home directory
RUN useradd -ms /bin/bash sims4fw
RUN echo "sims4fw ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user
USER sims4fw

# Set the working directory for the new user
WORKDIR /workspaces/s4fw

