# Repository: https://github.com/minouris/s4fw
#
# Project: S4FW
# Author: Ciara Norrish (@minouris)
# License: MIT (see LICENSE.md)
#
# Description: Dev container for Sims 4 Framework development

FROM ubuntu:20.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies and system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip zip sudo build-essential cmake libboost-all-dev tzdata jq \
    wget ca-certificates \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Build and install Python 3.7.0 from source
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz && \
    tar xzf Python-3.7.0.tgz && \
    cd Python-3.7.0 && \
    ./configure --enable-optimizations --with-ensurepip=install && \
    make -j"$(nproc)" && \
    make altinstall && \
    cd / && \
    rm -rf /tmp/Python-3.7.0*

# Create symlinks for python and pip
RUN ln -s /usr/local/bin/python3.7 /usr/local/bin/python && \
    ln -s /usr/local/bin/pip3.7 /usr/local/bin/pip

# Set fallback timezone (will be overridden by host mount if available)
ENV TZ=UTC

# Build and install pycdc
RUN git clone https://github.com/zrax/pycdc.git /opt/pycdc \
    && mkdir -p /opt/pycdc/build \
    && cd /opt/pycdc/build \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && make -j"$(nproc)" \
    && cp pycdc /usr/local/bin/pycdc \
    && chmod +x /usr/local/bin/pycdc \
    && rm -rf /opt/pycdc/build /opt/pycdc/.git

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