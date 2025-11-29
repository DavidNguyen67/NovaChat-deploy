# NovaChat VPS Stack

Full-stack production deployment (Next.js frontend + NestJS backend + Postgres + MongoDB + Redis) orchestrated via Docker Compose.

## Contents

- `docker-compose.vps.yml` service definitions
- `deploy.sh` guided deployment script
- `.env.example` (create from `.env.development`, do NOT commit real secrets)

## Architecture

Frontend (Next.js) → Backend (NestJS REST / WebSocket) → Databases (Postgres, MongoDB) + Cache (Redis) + External (Supabase storage). Internal bridge network `app-network`. Healthchecks ensure startup sequence.

Services:

- nextjs-app: Serves UI (port 3000)
- nestjs-app: API + auth + rate limiting (port 4000)
- postgres: Relational storage
- mongodb: Document storage
- redis: Cache / rate limiting
- supabase (external): Media storage

## Prerequisites

- Docker + Docker Compose v2
- Bash shell
- Access to Docker Hub images (`DOCKER_USERNAME/nextjs-app`, `DOCKER_USERNAME/nestjs-app`)
- Properly provisioned server firewall (open 3000 / 4000 only if needed)

## Setup

1. Copy env template:
   cp .env.development .env
2. Edit `.env` values (replace placeholders, rotate secrets, remove demo keys).
3. Log in to Docker:
   docker login
4. Pull images (optional manual):
   docker pull DOCKER_USERNAME/nextjs-app:latest
   docker pull DOCKER_USERNAME/nestjs-app:latest
5. Run deployment:
   ./deploy.sh (full stack)
   ./deploy.sh databases (only data layer)
   ./deploy.sh backend (API after databases)
   ./deploy.sh frontend (UI after backend)

## Environment Variables (summary)

Security: Never commit real secrets.

Core:

- DOCKER_USERNAME: Registry namespace
- FRONTEND_IMAGE_TAG / BACKEND_IMAGE_TAG: Image tags
- NODE_ENV: production | development

Auth / API:

- API_KEY: Internal service key (rotate)
- JWT_SECRET / JWT_REFRESH_SECRET: Min 32 chars
- JWT_EXPIRES_IN / JWT_REFRESH_EXPIRES_IN: e.g. 15m / 7d

Database:

- POSTGRES_USER / POSTGRES_PASSWORD / POSTGRES_DATABASE
- MONGO_ROOT_USERNAME / MONGO_ROOT_PASSWORD / MONGO_DATABASE
- REDIS_PASSWORD

External:

- SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY / SUPABASE_STORAGE_BUCKET
- MEDIA_ENDPOINT: Public media base

Frontend Public Config:

- NEXT_PUBLIC_FETCH_COUNT
- NEXT_PUBLIC_SOCKET_HOSTNAME / PORT / PATH / SECURE

Rate Limiting:

- THROTTLE_TTL / THROTTLE_LIMIT

## Deployment Script Highlights (`deploy.sh`)

- Loads `.env`
- Pulls images if tags provided
- Starts databases, waits for health
- Sequential startup with health probes
- Shows logs and prunes unused images

Usage:
./deploy.sh all
./deploy.sh backend
./deploy.sh frontend
./deploy.sh databases

## Healthchecks

- nextjs-app: GET /
- nestjs-app: GET /health
- postgres: pg_isready
- redis: INCR ping
- mongodb: ping command via mongosh

## Common Commands

View status:
docker-compose -f docker-compose.vps.yml ps
Tail logs:
docker-compose -f docker-compose.vps.yml logs -f nestjs-app
Restart a service:
docker-compose -f docker-compose.vps.yml restart redis
Stop all:
docker-compose -f docker-compose.vps.yml down

## Data Persistence

Named volumes:

- postgres_data
- redis_data
- mongodb_data
- mongodb_config

Backup recommendation (example):
docker run --rm -v postgres_data:/var/lib/postgresql/data -v $(pwd):/backup alpine tar -czf /backup/postgres_data.tar.gz /var/lib/postgresql/data

## Security Checklist

- Replace all placeholder secrets
- Enforce strong passwords (≥ 16 chars)
- Restrict ports via firewall (only 3000/4000 if public)
- Rotate API and JWT secrets regularly
- Disable default admin accounts externally
- Keep images updated (re-pull weekly)

## Troubleshooting

Frontend unhealthy:

- Check API_KEY and PROXY_ENDPOINT reachability.
  Backend unhealthy:
- Verify database containers show healthy.
  Mongo auth failure:
- Ensure username/password match `.env`.
  Redis failures:
- Confirm REDIS_PASSWORD matches command.
  Port conflicts:
- Ensure no host processes already occupy 3000 / 4000.

Check container health states:
docker inspect --format='{{.State.Health.Status}}' nestjs-app

## Extending

Add services by appending to `docker-compose.vps.yml` under same `app-network`. Use healthchecks for orderly sequencing.

## Cleanup

Remove stopped containers/images:
docker system prune -f

## Notes

- Do not commit `.env` with real secrets.
- Use tagged images for reproducibility (avoid mutable latest).
- Consider adding automated backups + monitoring (Prometheus / Grafana) later.

## License

Proprietary or specify appropriate license.
