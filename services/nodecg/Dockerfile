FROM node:22-slim

# Install git and other dependencies
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Create nodecg user
RUN useradd -m -s /bin/bash nodecg

# Set up NodeCG
WORKDIR /opt/nodecg

# Install NodeCG globally
RUN npm install -g nodecg

# Initialize NodeCG
RUN nodecg setup

# Clone required bundles
ARG BINGOTHON_LAYOUTS_BRANCH=master
RUN git clone -b ${BINGOTHON_LAYOUTS_BRANCH} https://github.com/bingothon/bingothon-layouts bundles/bingothon-layouts
RUN git clone https://github.com/speedcontrol/nodecg-speedcontrol bundles/nodecg-speedcontrol

# Change ownership of bundles before building (much faster)
RUN chown -R nodecg:nodecg /opt/nodecg/bundles

# Build the bingothon-layouts bundle as nodecg user
USER nodecg
WORKDIR /opt/nodecg/bundles/bingothon-layouts
RUN npm install && npm run build
WORKDIR /opt/nodecg

# Build the nodecg-speedcontrol bundle as nodecg user
WORKDIR /opt/nodecg/bundles/nodecg-speedcontrol
RUN npm install && npm run build
WORKDIR /opt/nodecg

# Switch back to root for copying config
USER root

# Copy configuration files
COPY cfg/ /opt/nodecg/cfg/

# Create assets directory and set ownership (only for new files)
RUN mkdir -p /opt/nodecg/assets && \
    chown -R nodecg:nodecg /opt/nodecg/cfg /opt/nodecg/assets

# Switch to nodecg user for final run
USER nodecg

# Expose port
EXPOSE 9090

# Start NodeCG
CMD ["nodecg", "start"]
