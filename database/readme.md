# Database Services - Hướng Dẫn

## Kiểm tra cấu hình

```bash
# Kiểm tra file .env.databases có đúng không
cat .env.databases

# Kiểm tra Docker Compose có đọc được env không
docker compose --env-file .env.databases -f docker-compose.databases.yml config

# Kiểm tra biến môi trường có được load không
docker compose --env-file .env.databases -f docker-compose.databases.yml config | grep -A 5 "environment:"
```

## Khởi động tất cả databases

```bash
docker compose --env-file .env.databases -f docker-compose.databases.yml up -d
```

## Xem logs

```bash
# Tất cả services
docker compose -f docker-compose.databases.yml logs -f

# Chỉ xem một service
docker logs postgres
docker logs redis
docker logs mongodb
```

## Kiểm tra trạng thái

```bash
# Xem tất cả containers đang chạy
docker compose -f docker-compose.databases.yml ps

# Kiểm tra health status
docker ps --filter "name=postgres" --format "table {{.Names}}\t{{.Status}}"
docker ps --filter "name=redis" --format "table {{.Names}}\t{{.Status}}"
docker ps --filter "name=mongodb" --format "table {{.Names}}\t{{.Status}}"
```

## Dừng databases

```bash
docker compose -f docker-compose.databases.yml down
```

## Xóa tất cả (bao gồm data)

```bash
docker compose -f docker-compose.databases.yml down -v
```

## Kết nối vào databases

### PostgreSQL

```bash
# Kết nối vào database
docker exec -it postgres psql -U novachat_admin -d novachat_db

# Kiểm tra connection string
docker exec -it postgres psql -U novachat_admin -d novachat_db -c "\conninfo"

# List databases
docker exec -it postgres psql -U novachat_admin -c "\l"
```

### Redis

```bash
# Kết nối Redis CLI
docker exec -it redis redis-cli

# Sau đó nhập: AUTH R3d1s_S3cur3_P4ss_2025!

# Hoặc kết nối trực tiếp với password
docker exec -it redis redis-cli -a R3d1s_S3cur3_P4ss_2025!

# Test connection
docker exec -it redis redis-cli -a R3d1s_S3cur3_P4ss_2025! PING
```

### MongoDB

```bash
# Kết nối MongoDB
docker exec -it mongodb mongosh -u mongodb_admin -p M0ng0_Sup3r_S3cur3_2025!

# List databases
docker exec -it mongodb mongosh -u mongodb_admin -p M0ng0_Sup3r_S3cur3_2025! --eval "show dbs"

# Test connection
docker exec -it mongodb mongosh -u mongodb_admin -p M0ng0_Sup3r_S3cur3_2025! --eval "db.adminCommand('ping')"
```

## Thông tin kết nối

| Database   | Host      | Port  | User           | Password                 | Database    |
| ---------- | --------- | ----- | -------------- | ------------------------ | ----------- |
| PostgreSQL | localhost | 5432  | novachat_admin | P@ssw0rd_N0v4Ch4t_2025!  | novachat_db |
| Redis      | localhost | 6379  | -              | R3d1s_S3cur3_P4ss_2025!  | -           |
| MongoDB    | localhost | 27017 | mongodb_admin  | M0ng0_Sup3r_S3cur3_2025! | novachat_db |

## Connection Strings

```bash
# PostgreSQL
postgresql://novachat_admin:P@ssw0rd_N0v4Ch4t_2025!@localhost:5432/novachat_db

# Redis
redis://:R3d1s_S3cur3_P4ss_2025!@localhost:6379

# MongoDB
mongodb://mongodb_admin:M0ng0_Sup3r_S3cur3_2025!@localhost:27017/novachat_db?authSource=admin
```

## Troubleshooting

```bash
# Xem logs nếu có lỗi
docker compose -f docker-compose.databases.yml logs postgres
docker compose -f docker-compose.databases.yml logs redis
docker compose -f docker-compose.databases.yml logs mongodb

# Kiểm tra biến môi trường trong container
docker exec postgres env | grep POSTGRES
docker exec redis env | grep REDIS
docker exec mongodb env | grep MONGO

# Restart một service cụ thể
docker compose -f docker-compose.databases.yml restart postgres
docker compose -f docker-compose.databases.yml restart redis
docker compose -f docker-compose.databases.yml restart mongodb
```
