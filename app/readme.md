# Application Services - Hướng Dẫn

## Kiểm tra cấu hình

```bash
# Kiểm tra file .env.development có đúng không
cat .env.development

# Kiểm tra Docker Compose có đọc được env không
docker compose --env-file .env.development -f docker-compose.app.yml config

# Kiểm tra biến môi trường có được load không
docker compose --env-file .env.development -f docker-compose.app.yml config | grep -A 5 "environment:"
```

## Khởi động tất cả services

```bash
docker compose --env-file .env.development -f docker-compose.app.yml up -d
```

## Xem logs

```bash
# Tất cả services
docker compose -f docker-compose.app.yml logs -f

# Chỉ xem một service
docker logs nextjs-app
docker logs nestjs-app
```

## Kiểm tra trạng thái

```bash
# Xem tất cả containers đang chạy
docker compose -f docker-compose.app.yml ps

# Kiểm tra health status
docker ps --filter "name=nextjs-app" --format "table {{.Names}}\t{{.Status}}"
docker ps --filter "name=nestjs-app" --format "table {{.Names}}\t{{.Status}}"
```

## Dừng services

```bash
docker compose -f docker-compose.app.yml down
```

## Xóa tất cả (bao gồm data)

```bash
docker compose -f docker-compose.app.yml down -v
```

## Truy cập vào containers

### Next.js Frontend

```bash
# Vào shell của container
docker exec -it nextjs-app sh

# Kiểm tra env variables
docker exec nextjs-app env | grep -E "NODE_ENV|PORT|PROXY"

# Xem logs trực tiếp
docker logs -f nextjs-app
```

### NestJS Backend

```bash
# Vào shell của container
docker exec -it nestjs-app sh

# Kiểm tra env variables
docker exec nestjs-app env | grep -E "NODE_ENV|APP_PORT|POSTGRES|MONGODB|REDIS"

# Xem logs trực tiếp
docker logs -f nestjs-app

# Xem logs từ volume
docker exec nestjs-app ls -la /app/logs
docker exec nestjs-app cat /app/logs/error.log
```

## Thông tin truy cập

| Service       | URL                   | Port | Container Name |
| ------------- | --------------------- | ---- | -------------- |
| Frontend (UI) | http://localhost:3000 | 3000 | nextjs-app     |
| Backend (API) | http://localhost:4000 | 4000 | nestjs-app     |

## API Endpoints Test

```bash
# Test Backend Health
curl http://localhost:4000/health

# Test Frontend
curl http://localhost:3000

# Test với API Key
curl -H "x-api-key: 5poiXiCWvNfQ}@~ma(Ob]Kee]}e]G%NcBU-U~m.Om(tjfsaE5B" http://localhost:4000/api/endpoint
```

## Connection Strings (từ Backend)

```bash
# PostgreSQL
postgresql://nova_app_postgres:kHTdV1GdR5BU6DAIwuB9c77noHfaTC@163.223.8.167:5432/nova_app

# MongoDB
mongodb://nova_app_mongo:6DUV3txZS4u3WIRzXk08kqhHcXmzOh@163.223.8.167:27017/nova_app?authSource=nova_app

# Redis
redis://:EJu609lEAhctvhsjLKwP6O8kUF9j7K@163.223.8.167:6379
```

## Rebuild và Deploy

```bash
# Pull latest images
docker pull ${DOCKER_USERNAME}/nova-app:latest
docker pull ${DOCKER_USERNAME}/nestjs-app:latest

# Restart với images mới
docker compose -f docker-compose.app.yml down
docker compose --env-file .env.development -f docker-compose.app.yml up -d

# Xem quá trình khởi động
docker compose -f docker-compose.app.yml logs -f
```

## Troubleshooting

```bash
# Xem logs nếu có lỗi
docker compose -f docker-compose.app.yml logs nextjs-app
docker compose -f docker-compose.app.yml logs nestjs-app

# Kiểm tra biến môi trường trong container
docker exec nextjs-app env
docker exec nestjs-app env

# Restart một service cụ thể
docker compose -f docker-compose.app.yml restart nextjs-app
docker compose -f docker-compose.app.yml restart nestjs-app

# Kiểm tra network
docker network inspect app_app-network

# Kiểm tra volumes
docker volume ls | grep app
docker volume inspect app_nestjs_logs

# Xem resource usage
docker stats nextjs-app nestjs-app
```

## Environment Variables

### Frontend (Next.js)

- `NODE_ENV`: development/production
- `PORT`: 3000
- `PROXY_ENDPOINT`: Backend API URL
- `API_KEY`: Authentication key

### Backend (NestJS)

- `NODE_ENV`: development/production
- `APP_PORT`: 4000
- `POSTGRES_URI`: PostgreSQL connection
- `MONGODB_URI`: MongoDB connection
- `REDIS_HOST`: Redis host
- `REDIS_PORT`: Redis port
- `REDIS_PASSWORD`: Redis password
- `JWT_SECRET`: JWT signing key

## Development vs Production

```bash
# Development
docker compose --env-file .env.development -f docker-compose.app.yml up -d

# Production (nếu có)
docker compose --env-file .env.production -f docker-compose.app.yml up -d
```
