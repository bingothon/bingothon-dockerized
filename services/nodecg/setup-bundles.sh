#!/bin/bash

# Script to set up NodeCG bundles on the host for development

set -e

BUNDLES_DIR="./bundles"

echo "Setting up NodeCG bundles for development..."

# Create bundles directory if it doesn't exist
mkdir -p "$BUNDLES_DIR"

# Clone bingothon-layouts if it doesn't exist
if [ ! -d "$BUNDLES_DIR/bingothon-layouts" ]; then
    echo "Cloning bingothon-layouts..."
    git clone -b ${BINGOTHON_LAYOUTS_BRANCH:-master} https://github.com/bingothon/bingothon-layouts "$BUNDLES_DIR/bingothon-layouts"
else
    echo "bingothon-layouts already exists, skipping clone"
fi

# Clone nodecg-speedcontrol if it doesn't exist
if [ ! -d "$BUNDLES_DIR/nodecg-speedcontrol" ]; then
    echo "Cloning nodecg-speedcontrol..."
    git clone https://github.com/speedcontrol/nodecg-speedcontrol "$BUNDLES_DIR/nodecg-speedcontrol"
else
    echo "nodecg-speedcontrol already exists, skipping clone"
fi

echo "Bundle setup complete!"
echo ""
echo "You can now:"
echo "1. Edit bundles directly in the $BUNDLES_DIR directory"
echo "2. Rebuild the container with: docker compose build nodecg"
echo "3. Or rebuild from the project root with: ./start.sh rebuild-api" 