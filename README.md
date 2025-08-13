# Bingothon NodeCG Setup

This repository contains a service-based setup for running NodeCG with Bingothon layouts.

## Structure

```
├── services/
│   ├── nodecg/           # NodeCG service
│   │   ├── Dockerfile    # Custom NodeCG image with bundles
│   │   ├── docker-compose.yml
│   │   └── cfg/          # NodeCG configuration
│   │       └── bingothon-layouts.json
│   └── mpd/              # MPD (Music Player Daemon) service
│       ├── Dockerfile    # MPD image configuration
│       ├── docker-compose.yml
│       ├── mpd.conf      # MPD configuration
│       └── add-music.sh  # Script to add music files
├── docker-compose.yml    # Main orchestrator
└── deploy.sh            # Deployment script
```

## Services

### NodeCG Service
- **Base Image**: `nodecg/nodecg:latest` (official NodeCG Docker image)
- **Customizations**: 
  - bingothon-layouts bundle
  - nodecg-speedcontrol bundle
  - Custom configuration
- **Port**: 9090
- **Volumes**: logs, db, assets

### MPD Service
- **Base Image**: `musicpd/mpd:latest` (official MPD Docker image)
- **Purpose**: Music Player Daemon for background music and audio control
- **Port**: 6600
- **Volumes**: music, playlists, data
- **Features**:
  - Supports MP3, OGG, FLAC, WAV formats
  - Network accessible for remote control
  - Integrated with bingothon-layouts bundle

## Usage

### Deploy with default branch (master)
```bash
./deploy.sh
```

### Deploy with specific branch
```bash
./deploy.sh develop
./deploy.sh feature/new-layout
```

### View logs
```bash
cd services/nodecg && docker compose logs -f
```

### Stop services
```bash
docker compose down
```

### Add music to MPD
You can add music in two ways:

**Option 1: Drag and drop (Recommended)**
```bash
# The music directory is mounted from the host
# Simply drag music files into: services/mpd/music/
# Then update the database:
cd services/mpd
./add-music.sh
```

**Option 2: Command line**
```bash
cd services/mpd
# Copy your music files to the music directory
cp /path/to/your/music/* ./music/
# Update the database
./add-music.sh
```

### Access NodeCG
Open http://localhost:9090 in your browser

## Configuration

The NodeCG configuration is stored in `services/nodecg/cfg/bingothon-layouts.json`. This file contains:
- OBS connection settings
- Discord bot configuration
- Donation tracker settings
- Firebase configuration
- MPD settings (enabled and configured for the MPD service)

The MPD configuration is stored in `services/mpd/mpd.conf` and includes:
- Audio format settings
- Network configuration
- Supported file formats
- Volume and replay gain settings

## Benefits of This Structure

1. **Clean Separation**: Each service has its own directory and configuration
2. **Official Base**: Uses the official NodeCG Docker image
3. **Easy Maintenance**: No need to maintain NodeCG code in this repo
4. **Scalable**: Easy to add more services
5. **Flexible**: Can override settings at the main compose level

## Adding New Services

To add a new service:

1. Create a new directory in `services/`
2. Add a `docker-compose.yml` for the service
3. Reference it in the main `docker-compose.yml` using `extends`
4. Update deployment scripts as needed
