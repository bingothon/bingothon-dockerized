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

# Clone required bundles (only if they don't exist)
ARG BINGOTHON_LAYOUTS_BRANCH=master
RUN if [ ! -d "bundles/bingothon-layouts" ]; then \
        git clone -b ${BINGOTHON_LAYOUTS_BRANCH} https://github.com/bingothon/bingothon-layouts bundles/bingothon-layouts; \
    fi
RUN if [ ! -d "bundles/nodecg-speedcontrol" ]; then \
        git clone https://github.com/speedcontrol/nodecg-speedcontrol bundles/nodecg-speedcontrol; \
    fi

# Change ownership of bundles before building (much faster)
RUN chown -R nodecg:nodecg /opt/nodecg/bundles

# Build the bingothon-layouts bundle as nodecg user (only if it exists)
USER nodecg
RUN if [ -d "/opt/nodecg/bundles/bingothon-layouts" ]; then \
        cd /opt/nodecg/bundles/bingothon-layouts && npm install && npm run build; \
    fi

# Build the nodecg-speedcontrol bundle as nodecg user (only if it exists)
RUN if [ -d "/opt/nodecg/bundles/nodecg-speedcontrol" ]; then \
        cd /opt/nodecg/bundles/nodecg-speedcontrol && npm install && npm run build; \
    fi

# Switch back to root for copying config
USER root

# Copy configuration files
COPY cfg/ /opt/nodecg/cfg/

# Create assets directory and set ownership (only for new files)
RUN mkdir -p /opt/nodecg/assets && \
    chown -R nodecg:nodecg /opt/nodecg/cfg /opt/nodecg/assets

# Switch to nodecg user for final run
USER nodecg

# Start NodeCG
CMD ["nodecg", "start"]
