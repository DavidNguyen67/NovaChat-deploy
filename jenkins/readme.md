# Jenkins CI/CD - Hướng Dẫn Đơn Giản

## Khởi động Jenkins

```bash
docker compose --env-file .env.jenkins -f docker-compose.jenkins.yml up -d
```

## Lấy mật khẩu admin đầu tiên

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

## Truy cập Jenkins

1. Mở trình duyệt: http://localhost:8080
2. Dán mật khẩu từ bước trên
3. Chọn "Install suggested plugins"
4. Tạo tài khoản admin của bạn
5. Xong!

## Xem logs

```bash
docker compose -f docker-compose.jenkins.yml logs -f
```

## Dừng Jenkins

```bash
docker compose -f docker-compose.jenkins.yml down
```

## Xóa tất cả (bao gồm data)

```bash
docker compose -f docker-compose.jenkins.yml down -v
```
