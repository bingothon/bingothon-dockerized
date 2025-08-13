#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🎵 Adding music to MPD service${NC}"

# Check if music directory exists
if [ ! -d "./music" ]; then
    echo -e "${YELLOW}📁 Creating music directory...${NC}"
    mkdir -p ./music
    echo -e "${GREEN}✅ Music directory created at ./music${NC}"
    echo -e "${YELLOW}💡 Place your music files in the ./music directory${NC}"
    echo -e "${YELLOW}💡 Supported formats: MP3, OGG, FLAC, WAV${NC}"
    exit 0
fi

# Check if there are music files
if [ -z "$(ls -A ./music 2>/dev/null)" ]; then
    echo -e "${YELLOW}📁 Music directory is empty${NC}"
    echo -e "${YELLOW}💡 Place your music files in the ./music directory${NC}"
    echo -e "${YELLOW}💡 Supported formats: MP3, OGG, FLAC, WAV${NC}"
    exit 0
fi

# Music directory is now mounted from host
echo -e "${GREEN}📁 Music directory is mounted from host${NC}"

# Get the MPD container name
CONTAINER_NAME=$(docker compose ps -q mpd 2>/dev/null)

if [ -z "$CONTAINER_NAME" ]; then
    echo -e "${RED}❌ MPD container is not running${NC}"
    echo -e "${YELLOW}💡 Start the MPD service first with: ./deploy.sh start${NC}"
    exit 1
fi

# Update MPD database
echo -e "${GREEN}🔄 Updating MPD database...${NC}"
docker exec $CONTAINER_NAME mpc update

echo -e "${GREEN}✅ Music added successfully!${NC}"
echo -e "${YELLOW}💡 You can now control MPD from the bingothon-layouts dashboard${NC}"
echo -e "${YELLOW}💡 Or use MPD clients to connect to localhost:6600${NC}" 