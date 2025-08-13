#!/bin/bash

# Startup script for NodeCG that builds bundles at runtime

echo "Starting NodeCG with bundle building..."

# Fix permissions for mounted bundles
echo "Fixing bundle permissions..."
chown -R nodecg:nodecg /opt/nodecg/bundles

# Switch to nodecg user for building and running
exec su -c "
# Build bundles if they exist (they should be mounted from host)
if [ -d '/opt/nodecg/bundles/bingothon-layouts' ]; then
    echo 'Building bingothon-layouts bundle...'
    cd /opt/nodecg/bundles/bingothon-layouts
    npm install
    npm run build
    cd /opt/nodecg
else
    echo 'Warning: bingothon-layouts bundle not found'
fi

if [ -d '/opt/nodecg/bundles/nodecg-speedcontrol' ]; then
    echo 'Building nodecg-speedcontrol bundle...'
    cd /opt/nodecg/bundles/nodecg-speedcontrol
    npm install
    npm run build
    cd /opt/nodecg
else
    echo 'Warning: nodecg-speedcontrol bundle not found'
fi

echo 'Starting NodeCG...'
exec nodecg start
" nodecg 