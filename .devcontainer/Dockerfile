FROM python:3.7-slim

# Install any build dependencies here
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*


# Install unpyc3 for decompiling Sims 4 .pyc files (install from GitHub, use as script)
RUN git clone https://github.com/andrew-tavera/unpyc3.git /opt/unpyc3
ENV PATH="/opt/unpyc3:${PATH}"

WORKDIR /workspace
