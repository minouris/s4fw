# Repository: https://github.com/minouris/s4fw
#
# Project: S4FW
# Author: Ciara Norrish (@minouris)
# License: MIT (see LICENSE.md)
#
# Description: Dev container for Sims 4 Framework development
#
# Revision: GIT_COMMIT_HASH

FROM python:3.7-slim



# Install any build dependencies here
RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip zip sudo build-essential cmake libboost-all-dev 

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
RUN pip install uncompyle6
RUN pip install decompyle3
RUN git clone https://github.com/andrews4s/unpyc37.git /opt/unpyc37

# Create a non-root user 'sims4fw' with home directory
RUN useradd -ms /bin/bash sims4fw
RUN echo "sims4fw ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user
USER sims4fw

# Set the working directory for the new user
WORKDIR /workspaces/s4fw