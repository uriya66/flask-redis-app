# 🚀 Flask Redis App with Jenkins CI/CD and Nginx Reverse Proxy

This project demonstrates a **professional DevOps pipeline** for a Flask + Redis application. It uses **Docker Compose** for container orchestration, **Nginx** as a reverse proxy, and **Jenkins** for CI/CD automation.

---

## 📦 Technologies Used

- **Flask** – Python micro web framework (development + production)
- **Redis** – In-memory key-value store
- **Gunicorn** – WSGI HTTP server (production only)
- **Nginx** – Reverse proxy (with SSL in production)
- **Docker & Docker Compose** – Container management
- **Jenkins** – Multibranch pipeline CI/CD with GitHub Webhook
- **Let's Encrypt + Certbot** – SSL management in production

---

## 🌐 Environments

| Environment   | Flask Internal Port | NGINX External Port | Access URL                            |
|---------------|---------------------|----------------------|----------------------------------------|
| Development   | 8087                | 8081                 | http://aws16.duckdns.org:8081/        |
| Production    | 8088                | 8082                 | https://aws16.duckdns.org:8082/       |

---

## 🧪 Health Checks

- **Flask**: Checked via `curl http://localhost:<internal-port>`
- **Redis**: Checked via `redis-cli ping`
- **Docker Compose**: Includes healthchecks for all containers

---

## ⚙️ Jenkins CI/CD Pipeline

- Multibranch Pipeline: detects `dev`, `main`, and version tags like `v1.0.0`
- **GitHub Webhook** triggers builds automatically on push
- **dev branch**:
  - Triggers Development Deployment
  - Uses `docker-compose.override.yml`
  - Serves via Nginx on port **8081**
- **main branch + tag (e.g., v1.0.0)**:
  - Triggers Production Deployment
  - Uses `docker-compose.prod.yml`
  - Serves via Nginx on port **8082**
- All logic defined in `Jenkinsfile`

---

## 🔐 Security

- Nginx in production supports **HTTPS** via Let's Encrypt
- SSL certificates managed via **Certbot**
- AWS Security Groups:
  - Only open required ports: `8081`, `8082`, `443`, and `22`
- Jenkins runs as a user with Docker access (`jenkins` in `docker` group)
- No sudo required for Docker commands in pipelines

---

## 🗂 Project Structure

flask-redis-app/
├── app/ # Flask application
├── certbot/ # SSL certificates and webroot for Let's Encrypt
├── nginx/
│ ├── dev.conf # Nginx config for development
│ └── prod.conf # Nginx config for production
├── docker-compose.yml # Base compose file
├── docker-compose.override.yml # Dev-specific overrides
├── docker-compose.prod.yml # Production overrides
├── Jenkinsfile # CI/CD pipeline definition
├── deploy_version.sh # Automates tagging, merging, rollback
├── .gitignore # Ignores logs/ and other local files
└── README.md # This file

---

## 🧹 Docker Cleanup & Modernization

- The `version:` field in all Compose files has been **removed** as it's deprecated in Docker Compose v1.27+.
- To clean unused containers/images:
  ```bash
  docker container prune -f
  docker image prune -f

---

## 📄 Docker Compose Summary

### `docker-compose.yml`  
Base services and networks. Defines:
- `web` container (exposes Flask internally)
- `redis` container (shared)
- `nginx` container (base)

### `docker-compose.override.yml` (Dev)
- Flask exposed on **8087**
- NGINX exposes port **8081**
- Flask runs with `flask run --reload`
- Hot reload and volume binding enabled

### `docker-compose.prod.yml` (Prod)
- Flask exposed on **8088**
- NGINX exposes port **8082**
- Flask runs with `gunicorn`
- Adds SSL mounts and NGINX production config

---

## 📤 Deployments

Handled via `deploy_version.sh`:

- Adds changes and pushes to `dev`
- Prompts merge to `main` with custom message
- Tags release version (`v1.0.0`)
- Pushes both `main` and the tag to GitHub
- Jenkins triggers full deployment

---

## 🧠 Tips & Troubleshooting

- Ensure ports `8081`, `8082`, and `443` are open in AWS
- To check what's using a port:
  sudo lsof -i :8081
  sudo lsof -i :8082

Check what process uses port 80/443:
  sudo lsof -i :80
  sudo lsof -i :443

Check logs if app not available:

  docker compose logs -f nginx
  docker compose logs -f web

Avoid binding NGINX to port 80 if using Certbot or other services

---

👤 Author

Managed by Jenkins CI/CD Jenkins Pipeline
Deployed to: aws16.duckdns.org
Maintained by: @uriya66 | DevOps Engineer

---
