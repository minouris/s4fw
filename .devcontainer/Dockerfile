FROM python:3.7-slim

# Install any build dependencies here
RUN apt-get update && apt-get install -y \
    git unzip zip sudo \
    && rm -rf /var/lib/apt/lists/*


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