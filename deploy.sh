set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

COMPOSE_FILE="docker-compose.vps.yml"
DEPLOY_TARGET=${1:-all}

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   🚀 VPS Full Stack Deployment       ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

if [ ! -f .env ]; then
    echo -e "${RED}❌ Error: .env file not found${NC}"
    echo "Please create .env file with required variables"
    exit 1
fi

echo -e "${YELLOW}📋 Loading environment variables...${NC}"
export $(cat .env | grep -v '^#' | grep -v '^$' | xargs)

if [ -z "$DOCKER_USERNAME" ]; then
    echo -e "${RED}❌ Error: DOCKER_USERNAME not set in .env${NC}"
    exit 1
fi

pull_frontend() {
    echo -e "${BLUE}📥 Pulling frontend image...${NC}"
    docker pull ${DOCKER_USERNAME}/nextjs-app:${FRONTEND_IMAGE_TAG:-latest}
}

pull_backend() {
    echo -e "${BLUE}📥 Pulling backend image...${NC}"
    docker pull ${DOCKER_USERNAME}/nestjs-app:${BACKEND_IMAGE_TAG:-latest}
}

deploy_databases() {
    echo -e "${MAGENTA}🗄️  Starting databases...${NC}"
    docker-compose -f ${COMPOSE_FILE} up -d postgres redis mongodb
    
    echo -e "${YELLOW}⏳ Waiting for databases to be healthy...${NC}"
    sleep 10
    
    for i in {1..30}; do
        if docker-compose -f ${COMPOSE_FILE} ps | grep -E "(postgres|redis|mongodb)" | grep -q "healthy"; then
            echo -e "${GREEN}✅ Databases are healthy${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
    done
    
    echo -e "${RED}❌ Databases failed to become healthy${NC}"
    docker-compose -f ${COMPOSE_FILE} ps
    exit 1
}

deploy_backend() {
    echo -e "${BLUE}🔧 Starting backend...${NC}"
    docker-compose -f ${COMPOSE_FILE} up -d nestjs-app
    
    echo -e "${YELLOW}⏳ Waiting for backend to be healthy...${NC}"
    sleep 5
    
    for i in {1..20}; do
        if docker-compose -f ${COMPOSE_FILE} ps nestjs-app | grep -q "healthy"; then
            echo -e "${GREEN}✅ Backend is healthy${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
    done
    
    echo -e "${YELLOW}⚠️  Backend is starting (may need more time)${NC}"
}

deploy_frontend() {
    echo -e "${BLUE}💻 Starting frontend...${NC}"
    docker-compose -f ${COMPOSE_FILE} up -d nextjs-app
    
    echo -e "${YELLOW}⏳ Waiting for frontend to be healthy...${NC}"
    sleep 5
    
    for i in {1..20}; do
        if docker-compose -f ${COMPOSE_FILE} ps nextjs-app | grep -q "healthy"; then
            echo -e "${GREEN}✅ Frontend is healthy${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
    done
    
    echo -e "${YELLOW}⚠️  Frontend is starting (may need more time)${NC}"
}

show_status() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${YELLOW}📊 Container Status:${NC}"
    docker-compose -f ${COMPOSE_FILE} ps
    echo ""
}

show_logs() {
    local service=$1
    echo -e "${YELLOW}📋 Recent logs for ${service}:${NC}"
    docker logs --tail 20 ${service}
    echo ""
}

cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up old images...${NC}"
    docker image prune -f
}

case $DEPLOY_TARGET in
    databases)
        echo -e "${BLUE}Deploying Databases only...${NC}"
        deploy_databases
        show_status
        ;;
    
    frontend)
        echo -e "${BLUE}Deploying Frontend only...${NC}"
        pull_frontend
        deploy_frontend
        show_status
        show_logs "nextjs-app"
        ;;
    
    backend)
        echo -e "${BLUE}Deploying Backend only...${NC}"
        pull_backend
        
        if ! docker-compose -f ${COMPOSE_FILE} ps | grep -E "(postgres|redis|mongodb)" | grep -q "Up"; then
            echo -e "${YELLOW}⚠️  Databases not running. Starting databases first...${NC}"
            deploy_databases
        fi
        
        deploy_backend
        show_status
        show_logs "nestjs-app"
        ;;
    
    all)
        echo -e "${BLUE}Deploying Full Stack...${NC}"
        echo ""
        
        echo -e "${CYAN}Step 1/4: Pulling Docker images${NC}"
        pull_frontend
        pull_backend
        echo ""
        
        echo -e "${CYAN}Step 2/4: Starting databases${NC}"
        deploy_databases
        echo ""
        
        echo -e "${CYAN}Step 3/4: Starting backend${NC}"
        deploy_backend
        echo ""
        
        echo -e "${CYAN}Step 4/4: Starting frontend${NC}"
        deploy_frontend
        echo ""
        
        show_status
        
        echo -e "${BLUE}Backend logs:${NC}"
        show_logs "nestjs-app"
        
        echo -e "${BLUE}Frontend logs:${NC}"
        show_logs "nextjs-app"
        
        cleanup
        ;;
    
    *)
        echo -e "${RED}❌ Invalid target: $DEPLOY_TARGET${NC}"
        echo ""
        echo "Usage: ./deploy-vps.sh [frontend|backend|databases|all]"
        echo ""
        echo "Options:"
        echo "  frontend   - Deploy frontend only"
        echo "  backend    - Deploy backend only"
        echo "  databases  - Deploy databases only"
        echo "  all        - Deploy full stack (default)"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      ✨ Deployment Completed! ✨      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

if [ "$DEPLOY_TARGET" == "all" ] || [ "$DEPLOY_TARGET" == "frontend" ]; then
    echo -e "${CYAN}🌐 Frontend:${NC} http://localhost:3000"
fi

if [ "$DEPLOY_TARGET" == "all" ] || [ "$DEPLOY_TARGET" == "backend" ]; then
    echo -e "${CYAN}🔧 Backend:${NC}  http://localhost:4000"
fi

echo ""
echo -e "${YELLOW}💡 Useful commands:${NC}"
echo "  View logs:    docker-compose -f ${COMPOSE_FILE} logs -f [service]"
echo "  Stop all:     docker-compose -f ${COMPOSE_FILE} down"
echo "  Restart:      docker-compose -f ${COMPOSE_FILE} restart [service]"
echo ""