# Database Services - Hướng Dẫn

## Khởi động tất cả databases

```bash
docker compose -f docker-compose.databases.yml up -d
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
docker exec -it postgres psql -U novachat_admin -d novachat_db
```

### Redis

```bash
docker exec -it redis redis-cli
# Sau đó nhập: AUTH R3d1s_S3cur3_P4ss_2025!
```

### MongoDB

```bash
docker exec -it mongodb mongosh -u mongodb_admin -p M0ng0_Sup3r_S3cur3_2025!
```

## Thông tin kết nối

| Database   | Host      | Port  | User           | Password                 |
| ---------- | --------- | ----- | -------------- | ------------------------ |
| PostgreSQL | localhost | 5432  | novachat_admin | P@ssw0rd_N0v4Ch4t_2025!  |
| Redis      | localhost | 6379  | -              | R3d1s_S3cur3_P4ss_2025!  |
| MongoDB    | localhost | 27017 | mongodb_admin  | M0ng0_Sup3r_S3cur3_2025! |
