# NovaChat VPS Deployment

Docker-based deployment configuration for NovaChat application stack including NextJS frontend, NestJS backend, and supporting services.

## 📋 Overview

This repository contains Docker Compose configurations for deploying a full-stack application with:

- **Frontend**: Next.js application
- **Backend**: NestJS API server
- **Databases**: PostgreSQL, MongoDB, Redis
- **CI/CD**: Jenkins with Docker-in-Docker

## 🏗️ Architecture

### Services

#### Application Stack (`docker-compose.app.yml`)

- **nextjs-app**: Frontend application (port 3000)
- **nestjs-app**: Backend API (port 4000)

#### Database Stack (`docker-compose.databases.yml`)

- **postgres**: PostgreSQL 16 (port 5432)
- **redis**: Redis 7 (port 6379)
- **mongodb**: MongoDB 7 (port 27017)

#### Jenkins Stack (`docker-compose.jenkins.yml`)

- **jenkins**: Jenkins LTS with JDK 17 (ports 8080, 50000)
- **docker-dind**: Docker-in-Docker for Jenkins builds

## 🚀 Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose v2.0+
- Minimum 4GB RAM
- 20GB free disk space

### Installation

1. **Clone the repository**

```bash
git clone <repository-url>
cd vps
```

2. **Create environment files**

```bash
# Copy example files
cp .env.example .env.development
cp .env.databases.example .env.databases
cp .env.jenkins.example .env.jenkins

# Edit with your values
nano .env.development
```

3. **Start databases**

```bash
docker compose -f docker-compose.databases.yml up -d
```

4. **Start applications**

```bash
docker compose -f docker-compose.app.yml up -d
```

5. **Start Jenkins (optional)**

```bash
docker compose -f docker-compose.jenkins.yml up -d
```

## ⚙️ Configuration

### Environment Files

#### `.env.development` - Application Configuration

```env
# Docker Images
DOCKER_USERNAME=your_docker_username
FRONTEND_IMAGE_NAME=nextjs-app
FRONTEND_IMAGE_TAG=latest
BACKEND_IMAGE_NAME=nestjs-app
BACKEND_IMAGE_TAG=latest

# Application
NODE_ENV=development
FRONTEND_PORT=3000
BACKEND_PORT=4000

# API & Proxy
API_KEY=your_api_key_here
PROXY_ENDPOINT=http://nestjs-app:4000
PROXY_API_KEY=your_api_key_here

# Database URIs
POSTGRES_URI=postgresql://postgres:password@postgres:5432/myapp_db
MONGODB_URI=mongodb://admin:password@mongodb:27017/myapp_db?authSource=admin
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password

# JWT
JWT_SECRET=your_jwt_secret_min_32_chars
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=your_refresh_secret_min_32_chars
JWT_REFRESH_EXPIRES_IN=7d
```

#### `.env.databases` - Database Configuration

```env
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_strong_password
POSTGRES_DATABASE=myapp_db
POSTGRES_PORT=5432

# MongoDB
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=your_strong_password
MONGO_PORT=27017

# Redis
REDIS_PASSWORD=your_strong_password
REDIS_PORT=6379
```

#### `.env.jenkins` - Jenkins Configuration

```env
# Jenkins
JENKINS_WEB_PORT=8080
JENKINS_AGENT_PORT=50000

# Docker-in-Docker
DOCKER_TLS_CERTDIR=/certs
DOCKER_STORAGE_DRIVER=overlay2
DOCKER_HOST=tcp://docker:2376
DOCKER_CERT_PATH=/certs/client
DOCKER_TLS_VERIFY=1
```

## 📝 Usage

### Managing Services

```bash
# Start all services
docker compose -f docker-compose.databases.yml -f docker-compose.app.yml up -d

# Stop all services
docker compose -f docker-compose.databases.yml -f docker-compose.app.yml down

# View logs
docker compose -f docker-compose.app.yml logs -f

# Restart specific service
docker compose -f docker-compose.app.yml restart nextjs-app

# Check service health
docker compose -f docker-compose.databases.yml ps
```

### Database Backups

Backup directories are mounted at:

- PostgreSQL: `./backups/postgres`
- MongoDB: `./backups/mongodb`
- Redis: `./backups/redis`

### Accessing Services

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:4000
- **Jenkins**: http://localhost:8080
- **PostgreSQL**: localhost:5432
- **MongoDB**: localhost:27017
- **Redis**: localhost:6379

## 🔧 Development

### Building Images

```bash
# Build frontend
docker build -t ${DOCKER_USERNAME}/nextjs-app:latest ./frontend

# Build backend
docker build -t ${DOCKER_USERNAME}/nestjs-app:latest ./backend

# Push to registry
docker push ${DOCKER_USERNAME}/nextjs-app:latest
docker push ${DOCKER_USERNAME}/nestjs-app:latest
```

### Running in Development Mode

The application uses `NODE_ENV=development` by default with hot-reload enabled.

## 🐛 Troubleshooting

### Common Issues

**Services won't start**

```bash
# Check logs
docker compose logs <service-name>

# Verify environment variables
docker compose config

# Check port conflicts
netstat -ano | findstr "3000 4000 5432"
```

**Database connection errors**

- Ensure databases are healthy: `docker compose ps`
- Check connection strings in `.env.development`
- Verify network connectivity: `docker network ls`

**Permission errors**

```bash
# Fix volume permissions
docker compose down -v
docker volume prune
```

## 📊 Monitoring

### Health Checks

All services include health checks:

- **PostgreSQL**: `pg_isready`
- **Redis**: `redis-cli ping`
- **MongoDB**: `mongosh ping`
- **Applications**: HTTP endpoints

### Logs

```bash
# View all logs
docker compose logs -f

# Filter by service
docker compose logs -f nextjs-app

# Last 100 lines
docker compose logs --tail=100
```

## 🔒 Security

- Never commit `.env` files with real credentials
- Use strong passwords (min 32 characters for JWT secrets)
- Keep Docker images updated
- Use secrets management in production
- Enable TLS for external connections

## 📚 Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Next.js Documentation](https://nextjs.org/docs)
- [NestJS Documentation](https://docs.nestjs.com)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Redis Documentation](https://redis.io/docs/)

## 📄 License

[Your License Here]

## 👥 Contributing

[Your Contributing Guidelines Here]
