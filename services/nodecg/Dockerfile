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

# Create bundles directory (bundles will be mounted from host)
RUN mkdir -p /opt/nodecg/bundles

# Change ownership of bundles before building (much faster)
RUN chown -R nodecg:nodecg /opt/nodecg/bundles

# Copy startup script
COPY start.sh /opt/nodecg/start.sh
RUN chmod +x /opt/nodecg/start.sh

# Switch back to root for copying config
USER root

# Copy configuration files
COPY cfg/ /opt/nodecg/cfg/

# Create assets directory and set ownership (only for new files)
RUN mkdir -p /opt/nodecg/assets && \
    chown -R nodecg:nodecg /opt/nodecg/cfg /opt/nodecg/assets

# Start NodeCG with bundle building (run as root to fix permissions)
CMD ["/opt/nodecg/start.sh"]
