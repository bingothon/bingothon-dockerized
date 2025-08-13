#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Set UID and GID for Docker user mapping (for proper volume permissions)
export DOCKER_UID=${UID:-$(id -u)}
export DOCKER_GID=${GID:-$(id -g)}

# Parse command line arguments
COMMAND="${1:-start}"
BINGOTHON_LAYOUTS_BRANCH="master"
NO_CACHE=false

# Check for options
while [[ $# -gt 0 ]]; do
    case $1 in
        --branch)
            if [[ -n "$2" ]]; then
                BINGOTHON_LAYOUTS_BRANCH="$2"
                shift 2
            else
                echo -e "${RED}❌ Error: --branch requires a branch name${NC}"
                exit 1
            fi
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        start|stop|restart|build|rebuild|logs|status|clean|music|help|-h|--help)
            COMMAND="$1"
            shift
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            echo ""
            print_usage
            exit 1
            ;;
    esac
done

# Function to print usage
print_usage() {
    echo -e "${BLUE}🎮 Bingothon NodeCG Service Manager${NC}"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
           echo "Commands:"
       echo "  start     - Start all services"
       echo "  stop      - Stop all services"
       echo "  restart   - Restart all services"
       echo "  build     - Build all services"
       echo "  rebuild   - Rebuild all services (with cache)"
       echo "  logs      - Show logs for all services"
       echo "  status    - Show status of all services"
       echo "  clean     - Stop and remove all containers, networks, and volumes"
       echo "  music     - Add music to MPD service"
       echo "  help      - Show this help message"
    echo ""
           echo "Options:"
       echo "  --branch BRANCH  - Specify bingothon-layouts branch (default: master)"
       echo "  --no-cache       - Force rebuild without using Docker cache"
    echo ""
           echo "Examples:"
       echo "  $0 start                    # Start all services with master branch"
       echo "  $0 start --branch develop   # Start all services with develop branch"
       echo "  $0 stop                     # Stop all services"
       echo "  $0 rebuild                  # Rebuild with cache (fast)"
       echo "  $0 rebuild --no-cache       # Rebuild without cache (slow)"
       echo "  $0 build --no-cache         # Build without cache"
       echo "  $0 logs                     # Show logs"
       echo "  $0 music                    # Add music to MPD"
}

# Function to check if config file exists
check_config() {
    if [ ! -f "./services/nodecg/cfg/bingothon-layouts.json" ]; then
        echo -e "${RED}❌ Error: ./services/nodecg/cfg/bingothon-layouts.json not found!${NC}"
        echo "Please ensure your configuration file exists in the services/nodecg/cfg directory."
        exit 1
    fi
}

# Function to check and setup bundles if needed
check_and_setup_bundles() {
    if [ ! -d "./services/nodecg/bundles" ] || [ ! -d "./services/nodecg/bundles/bingothon-layouts" ] || [ ! -d "./services/nodecg/bundles/nodecg-speedcontrol" ]; then
        echo -e "${YELLOW}📦 Setting up NodeCG bundles...${NC}"
        cd services/nodecg
        BINGOTHON_LAYOUTS_BRANCH=${BINGOTHON_LAYOUTS_BRANCH} ./setup-bundles.sh
        cd ../..
    else
        echo -e "${GREEN}✅ NodeCG bundles already exist${NC}"
    fi
}

# Function to create network if it doesn't exist
create_network() {
    if ! docker network ls | grep -q "bingothon-network"; then
        echo -e "${YELLOW}🌐 Creating bingothon-network...${NC}"
        docker network create bingothon-network
    fi
}

# Function to start services
start_services() {
    echo -e "${GREEN}🚀 Starting Bingothon NodeCG Services${NC}"
    echo -e "${YELLOW}📦 Using bingothon-layouts branch: ${BINGOTHON_LAYOUTS_BRANCH}${NC}"
    echo -e "${BLUE}👤 Using UID: ${DOCKER_UID}, GID: ${DOCKER_GID}${NC}"
    
    check_config
    check_and_setup_bundles
    create_network
    
    # Start NodeCG service
    echo -e "${YELLOW}🔧 Starting NodeCG service...${NC}"
    cd services/nodecg
    BINGOTHON_LAYOUTS_BRANCH=${BINGOTHON_LAYOUTS_BRANCH} docker compose up -d
    cd ../..
    
    # Start MPD service
    echo -e "${YELLOW}🎵 Starting MPD service...${NC}"
    cd services/mpd
    docker compose up -d
    cd ../..
    
    echo -e "${GREEN}✅ All services started!${NC}"
    echo -e "${YELLOW}📋 View logs with: $0 logs${NC}"
    echo -e "${YELLOW}🌐 Access NodeCG at: http://localhost:9090${NC}"
    echo -e "${YELLOW}🎵 MPD running on port 6600${NC}"
    echo -e "${YELLOW}🛑 Stop with: $0 stop${NC}"
}

# Function to stop services
stop_services() {
    echo -e "${YELLOW}🛑 Stopping Bingothon NodeCG Services${NC}"
    
    # Stop MPD service
    echo -e "${YELLOW}🎵 Stopping MPD service...${NC}"
    cd services/mpd
    docker compose down
    cd ../..
    
    # Stop NodeCG service
    echo -e "${YELLOW}🔧 Stopping NodeCG service...${NC}"
    cd services/nodecg
    docker compose down
    cd ../..
    
    echo -e "${GREEN}✅ All services stopped!${NC}"
}

# Function to restart services
restart_services() {
    echo -e "${YELLOW}🔄 Restarting Bingothon NodeCG Services${NC}"
    stop_services
    sleep 2
    start_services
}

# Function to build services
build_services() {
    local cache_flag=""
    if [ "$NO_CACHE" = true ]; then
        cache_flag="--no-cache"
        echo -e "${GREEN}🔨 Building Bingothon NodeCG Services (no cache)${NC}"
    else
        echo -e "${GREEN}🔨 Building Bingothon NodeCG Services${NC}"
    fi
    echo -e "${YELLOW}📦 Using bingothon-layouts branch: ${BINGOTHON_LAYOUTS_BRANCH}${NC}"
    
    check_config
    check_and_setup_bundles
    create_network
    
    # Build NodeCG service
    echo -e "${YELLOW}🔧 Building NodeCG service...${NC}"
    cd services/nodecg
    BINGOTHON_LAYOUTS_BRANCH=${BINGOTHON_LAYOUTS_BRANCH} docker compose build $cache_flag
    cd ../..
    
    # Build MPD service
    echo -e "${YELLOW}🎵 Building MPD service...${NC}"
    cd services/mpd
    docker compose build $cache_flag
    cd ../..
    
    echo -e "${GREEN}✅ All services built!${NC}"
    echo -e "${YELLOW}💡 Start services with: $0 start${NC}"
}

# Function to rebuild services (with cache)
rebuild_services() {
    local cache_flag=""
    if [ "$NO_CACHE" = true ]; then
        cache_flag="--no-cache"
        echo -e "${GREEN}🔨 Rebuilding Bingothon NodeCG Services (no cache)${NC}"
    else
        echo -e "${GREEN}🔨 Rebuilding Bingothon NodeCG Services (with cache)${NC}"
    fi
    echo -e "${YELLOW}📦 Using bingothon-layouts branch: ${BINGOTHON_LAYOUTS_BRANCH}${NC}"
    
    check_config
    check_and_setup_bundles
    create_network
    
    # Rebuild NodeCG service
    echo -e "${YELLOW}🔧 Rebuilding NodeCG service...${NC}"
    cd services/nodecg
    BINGOTHON_LAYOUTS_BRANCH=${BINGOTHON_LAYOUTS_BRANCH} docker compose build $cache_flag
    cd ../..
    
    # Rebuild MPD service
    echo -e "${YELLOW}🎵 Rebuilding MPD service...${NC}"
    cd services/mpd
    docker compose build $cache_flag
    cd ../..
    
    echo -e "${GREEN}✅ All services rebuilt!${NC}"
    echo -e "${YELLOW}💡 Start services with: $0 start${NC}"
}



# Function to show logs
show_logs() {
    echo -e "${BLUE}📋 Bingothon NodeCG Services Logs${NC}"
    echo ""
    echo -e "${YELLOW}🔧 NodeCG Logs:${NC}"
    cd services/nodecg
    docker compose logs --tail=50
    cd ../..
    echo ""
    echo -e "${YELLOW}🎵 MPD Logs:${NC}"
    cd services/mpd
    docker compose logs --tail=50
    cd ../..
}

# Function to show status
show_status() {
    echo -e "${BLUE}📊 Bingothon NodeCG Services Status${NC}"
    echo ""
    
    # Check if network exists
    if docker network ls | grep -q "bingothon-network"; then
        echo -e "${GREEN}✅ Network: bingothon-network${NC}"
    else
        echo -e "${RED}❌ Network: bingothon-network (not found)${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}🔧 NodeCG Service:${NC}"
    cd services/nodecg
    docker compose ps
    cd ../..
    
    echo ""
    echo -e "${YELLOW}🎵 MPD Service:${NC}"
    cd services/mpd
    docker compose ps
    cd ../..
}

# Function to clean everything
clean_all() {
    echo -e "${RED}🧹 Cleaning all Bingothon NodeCG Services${NC}"
    echo -e "${YELLOW}⚠️  This will remove all containers, networks, and volumes!${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🛑 Stopping all services...${NC}"
        stop_services
        
        echo -e "${YELLOW}🗑️  Removing containers...${NC}"
        docker container prune -f
        
        echo -e "${YELLOW}🌐 Removing networks...${NC}"
        docker network rm bingothon-network 2>/dev/null || true
        
        echo -e "${YELLOW}💾 Removing volumes...${NC}"
        docker volume prune -f
        
        echo -e "${GREEN}✅ Cleanup complete!${NC}"
    else
        echo -e "${YELLOW}❌ Cleanup cancelled${NC}"
    fi
}

# Function to add music
add_music() {
    echo -e "${GREEN}🎵 Adding music to MPD service${NC}"
    cd services/mpd
    ./add-music.sh
    cd ../..
}

# Main script logic
case "$COMMAND" in
    "start")
        start_services
        ;;
    "stop")
        stop_services
        ;;
    "restart")
        restart_services
        ;;
    "build")
        build_services
        ;;
    "rebuild")
        rebuild_services
        ;;
    "logs")
        show_logs
        ;;
    "status")
        show_status
        ;;
    "clean")
        clean_all
        ;;
    "music")
        add_music
        ;;
    "help"|"-h"|"--help")
        print_usage
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        echo ""
        print_usage
        exit 1
        ;;
esac
