#!/bin/bash

# setup-nginx-ssl.sh - Setup Nginx Reverse Proxy + SSL
# ===========================================
# Run this on VPS after deployment
# ===========================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Nginx + SSL Setup Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   echo -e "${YELLOW}Please run: sudo ./setup-nginx-ssl.sh${NC}"
   exit 1
fi

# Get domain names
echo -e "${YELLOW}Enter your domain names:${NC}"
read -p "Frontend domain (e.g., yourdomain.com): " FRONTEND_DOMAIN
read -p "Backend API domain (e.g., api.yourdomain.com): " BACKEND_DOMAIN
read -p "Your email for SSL certificates: " EMAIL

echo ""
echo -e "${GREEN}Configuration:${NC}"
echo -e "  Frontend: ${FRONTEND_DOMAIN}"
echo -e "  Backend:  ${BACKEND_DOMAIN}"
echo -e "  Email:    ${EMAIL}"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# ===========================================
# Step 1: Install Nginx
# ===========================================
echo -e "${BLUE}[1/6] Installing Nginx...${NC}"
apt update
apt install -y nginx
systemctl enable nginx
systemctl start nginx
echo -e "${GREEN}✓ Nginx installed${NC}"
echo ""

# ===========================================
# Step 2: Create Nginx config
# ===========================================
echo -e "${BLUE}[2/6] Creating Nginx configuration...${NC}"

cat > /etc/nginx/sites-available/fullstack-app << EOF
# Backend API Server
upstream backend {
    server localhost:4000;
}

# Frontend Server
upstream frontend {
    server localhost:3000;
}

# Backend API
server {
    listen 80;
    server_name ${BACKEND_DOMAIN};

    client_max_body_size 50M;

    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}

# Frontend
server {
    listen 80;
    server_name ${FRONTEND_DOMAIN} www.${FRONTEND_DOMAIN};

    location / {
        proxy_pass http://frontend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

echo -e "${GREEN}✓ Configuration created${NC}"
echo ""

# ===========================================
# Step 3: Enable site
# ===========================================
echo -e "${BLUE}[3/6] Enabling site...${NC}"
ln -sf /etc/nginx/sites-available/fullstack-app /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx
echo -e "${GREEN}✓ Site enabled${NC}"
echo ""

# ===========================================
# Step 4: Install Certbot
# ===========================================
echo -e "${BLUE}[4/6] Installing Certbot...${NC}"
apt install -y certbot python3-certbot-nginx
echo -e "${GREEN}✓ Certbot installed${NC}"
echo ""

# ===========================================
# Step 5: Setup SSL
# ===========================================
echo -e "${BLUE}[5/6] Setting up SSL certificates...${NC}"
echo -e "${YELLOW}This will request SSL certificates from Let's Encrypt${NC}"
echo ""

# Frontend SSL
certbot --nginx -d ${FRONTEND_DOMAIN} -d www.${FRONTEND_DOMAIN} \
    --non-interactive \
    --agree-tos \
    --email ${EMAIL} \
    --redirect

# Backend SSL
certbot --nginx -d ${BACKEND_DOMAIN} \
    --non-interactive \
    --agree-tos \
    --email ${EMAIL} \
    --redirect

echo -e "${GREEN}✓ SSL certificates installed${NC}"
echo ""

# ===========================================
# Step 6: Setup auto-renewal
# ===========================================
echo -e "${BLUE}[6/6] Setting up SSL auto-renewal...${NC}"
systemctl enable certbot.timer
systemctl start certbot.timer
echo -e "${GREEN}✓ Auto-renewal configured${NC}"
echo ""

# ===========================================
# Configure firewall
# ===========================================
echo -e "${BLUE}Configuring firewall...${NC}"
ufw allow 'Nginx Full'
ufw allow OpenSSH
echo "y" | ufw enable
echo -e "${GREEN}✓ Firewall configured${NC}"
echo ""

# ===========================================
# Final status
# ===========================================
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✓ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Your sites are now available:${NC}"
echo -e "  Frontend: ${GREEN}https://${FRONTEND_DOMAIN}${NC}"
echo -e "  Backend:  ${GREEN}https://${BACKEND_DOMAIN}${NC}"
echo ""
echo -e "${YELLOW}SSL certificates will auto-renew every 90 days${NC}"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo -e "  Test renewal:    ${CYAN}certbot renew --dry-run${NC}"
echo -e "  Nginx reload:    ${CYAN}systemctl reload nginx${NC}"
echo -e "  Check status:    ${CYAN}systemctl status nginx${NC}"
echo -e "  View logs:       ${CYAN}tail -f /var/log/nginx/error.log${NC}"
echo ""