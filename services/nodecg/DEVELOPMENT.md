# NodeCG Development Setup

This setup allows you to develop NodeCG bundles directly on your host machine while running NodeCG in a Docker container.

## Quick Start

1. **Set up bundles on the host:**
   ```bash
   cd services/nodecg
   ./setup-bundles.sh
   ```

2. **Build and start the container:**
   ```bash
   # From the project root
   ./start.sh rebuild-api && ./start.sh api
   ```

## Development Workflow

### Bundle Structure
The bundles are now exposed on the host at `services/nodecg/bundles/`:
- `bingothon-layouts/` - Main layout bundle
- `nodecg-speedcontrol/` - Speed control bundle

### Making Changes
1. Edit files directly in the `bundles/` directory on your host
2. For most changes, NodeCG will auto-reload
3. For bundle rebuilds, restart the container:
   ```bash
   ./start.sh rebuild-api && ./start.sh api
   ```

### Bundle Development Tips
- Changes to bundle configuration files require a container restart
- Changes to frontend files (HTML, CSS, JS) usually auto-reload
- Changes to backend files (Node.js) may require a container restart
- Use the NodeCG dashboard at `http://localhost:9090` to monitor bundle status

## Environment Variables
- `BINGOTHON_LAYOUTS_BRANCH` - Set the branch for bingothon-layouts (default: master)

## Troubleshooting
- If bundles don't appear, ensure they're properly cloned in the `bundles/` directory
- Check container logs: `docker compose logs nodecg`
- Verify volume mounts: `docker compose exec nodecg ls -la /opt/nodecg/bundles` 