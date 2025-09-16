FROM python:3.7-slim

# Install any build dependencies here
RUN apt-get update && apt-get install -y \
    git unzip zip \
    && rm -rf /var/lib/apt/lists/*


# Install unpyc3 for decompiling Sims 4 .pyc files (install from GitHub, use as script)
RUN pip install uncompyle6

# Create a non-root user 'sims4fw' with home directory
RUN useradd -ms /bin/bash sims4fw

# Switch to the new user
USER sims4fw

# Set the working directory for the new user
WORKDIR /workspaces/s4fw