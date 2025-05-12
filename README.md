# 🚀 Flask Redis App with Jenkins CI/CD and Nginx Reverse Proxy

This project demonstrates a **production-grade DevOps pipeline** for a Flask + Redis application.  
It features **Docker Compose**, **Nginx as reverse proxy**, **SSL with Certbot**, and **Jenkins CI/CD**.

---

## ⚙️ Technologies

- **Flask** – Python web app
- **Redis** – Key-value store
- **Gunicorn** – WSGI server for production
- **Docker & Compose** – Container orchestration
- **Jenkins** – Multibranch pipeline with GitHub Webhook
- **Nginx** – Reverse proxy
- **Certbot (Let's Encrypt)** – SSL certificates
- **Snyk** – Security scans for Docker Images

---

## 🌐 Environment Configuration

| Environment   | Flask Internal | NGINX External | Access URL                         |
|---------------|----------------|----------------|-------------------------------------|
| Development   | 8087           | 8081           | http://aws16.duckdns.org:8081      |
| Production    | 8088           | 8082           | https://aws16.duckdns.org:8082     |

---

## 🐳 Docker Image Optimization

- **Alpine base image**: Small footprint (~60MB instead of 1.02GB)
- **Multi-stage builds**: Split between build-time and runtime layers
- **No cache**: `pip install --no-cache-dir` to reduce size
- **Precise copy**: Only `app/` is copied – no `.git`, `.env`, etc.
- **Security scan**: Use `snyk test --docker` to detect vulnerabilities
- **Run as non-root**: The app runs as `appuser` inside the container using `USER`, enhancing runtime security.
- **Dynamic build labels**: Jenkins injects the Git tag into the image via `ARG BUILD_VERSION` and `LABEL version=...` – allowing version traceability in `docker inspect`.
- **Security scanning**: Images are scanned by **Snyk** as part of the Jenkins pipeline.

---

## 🔧 Dockerfile Optimization Summary

This project uses a production-optimized Dockerfile based on best practices:

| Line in Dockerfile           | What it does                     | Real-world impact on your project                                                                 |
|-----------------------------|----------------------------------|---------------------------------------------------------------------------------------------------|
| `FROM python:3.11-alpine`   | Uses Alpine Linux base image     | Reduces image size drastically (~60MB). Faster build & deploy. Requires manual dependency install. |
| `apk add ...` in builder    | Adds GCC and build tools         | Needed for installing packages like `gunicorn`. Removed from final image via multi-stage build.    |
| `Multi-stage build`         | Builds then copies result        | Keeps final image minimal – no pip cache, no compilers, no temp files. Enhances security & speed.  |
| `--no-cache-dir`            | Disables pip cache               | Saves space by not saving unnecessary files in image (~30-50MB saved depending on packages).       |
| `COPY app/ .`               | Copies only the app folder       | Avoids leaking `.git`, `.env`, IDE configs – ensures clean and secure deployment.                  |

> 🔐 If someone builds your image, they do **not need to manually install anything**.  
> As long as they run `docker build .`, the Dockerfile handles all steps: installing, copying, and preparing the app.
> 🧑‍💻 The Dockerfile also:
> - Creates a non-root user `appuser` with `adduser -D appuser` for secure runtime.
> - Accepts a dynamic build argument `BUILD_VERSION` from Jenkins and injects it into image labels.
> - Ensures reproducibility and traceability using `LABEL version="${BUILD_VERSION}"`.

> You can inspect metadata with:
> ```bash
> docker inspect flask-redis-app:latest
> ```
> And search for:
> ```json
> "Labels": {
>   "version": "v1.0.3",
>   ...
> }
> ```


---

## 🗃️ MySQL Integration (2025-05-12)

This project now includes a **fully integrated MySQL database** for both development and production environments.

- **Dockerized MySQL**: Defined in all `docker-compose` files with environment variables:
  - `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`
- **Persistent Volumes**: Each environment uses a separate named volume (`mysql_data`) for data persistence.
- **Auto Port Mapping (Dev)**: In `docker-compose.override.yml`, port `3307` on the host maps to MySQL `3306` for local access.
- **Secure in Prod**: No external MySQL ports are exposed in production.
- **Flask Integration**:
  - The Flask app connects to Redis *and* MySQL.
  - A test route `/` creates a `visits` table and logs data to it.
  - Both Redis and MySQL values are displayed in the browser.
- **Automatic Table Creation**: On first launch, `visits` table is created if not exists.
- **Auto Insert & Fetch**: Every refresh inserts a row and fetches all values for display.

This allows your app to demonstrate:
- Full DB connectivity
- Safe stateful persistence
- Real-world Flask + MySQL logic

---

## 🧪 Health Checks

- `web`: `curl http://localhost:8087` or `8088`
- `redis`: `redis-cli ping`
- Defined in `docker-compose.yml` as part of `healthcheck`

---

## 🧬 Jenkins Pipeline Overview

- `Jenkinsfile` includes:
  - Git context detection: branch vs tag
  - Build image with tag/version
  - Deploy to Dev (port 8087) or Prod (port 8088)
  - Triggered via GitHub Webhook
- Slack notifications included (via `post` block)

---

## 🔐 Docker Security & Metadata Integration

This project applies container security best practices:

- Non-root user execution (appuser) inside the Dockerfile for enhanced runtime safety.
- Multi-stage build ensures only production-ready files are shipped – no dev tools or caches.
- Metadata labels (LABEL) are added dynamically based on the Git tag (version) via ARG BUILD_VERSION from Jenkins.
- Snyk Security Scan runs inside the Jenkins pipeline (Security Scan stage) and inspects:
- The final Docker image (--docker)
- Python packages from requirements.txt (inside the image)
- All vulnerabilities (CVEs) are printed and reviewed during the build without failing the pipeline.


These steps ensure your images are:

- Lightweight
- Traceable by version
- Secure by default
- CI-aware and auditable

✅ This gives your production images a real-world DevSecOps touch with minimum effort.

---

## 🗂 Project Structure

```bash
flask-redis-app/
├── app/                     # Flask application
│   ├── static/images/       # Static assets (e.g., docker logo)
│   │   └── docker logo.png
│   ├── templates/           # HTML templates for Flask
│   │   └── index.html
│   ├── app.py               # Main Flask application logic
│   └── requirements.txt     # Python dependencies
│
├── nginx/                   # Nginx reverse proxy configs
│   ├── default.conf
│   ├── dev.conf
│   └── prod.conf
│
├── .gitignore               # Git ignored files
├── .dockerignore            # Docker build ignored files
├── Dockerfile               # Docker Image build instructions
├── Jenkinsfile              # Jenkins CI/CD pipeline
├── README.md                # Project documentation
├── deploy_version.sh        # Bash script for tagging + release automation
│
├── docker-compose.yml               # Base docker-compose definition
├── docker-compose.override.yml      # Dev-specific config (port 8087 + hot reload)
├── docker-compose.prod.yml          # Prod-specific config (port 8088 + Gunicorn + SSL)

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
