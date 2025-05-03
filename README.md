# Flask Redis App with Jenkins CI/CD and Nginx Reverse Proxy

This project demonstrates a professional DevOps setup for a Flask application with Redis, deployed using Docker Compose, and managed via Jenkins CI/CD pipelines. Nginx acts as a reverse proxy for both development and production environments.

---

## 📦 Technologies Used

- **Flask** – Python micro web framework
- **Redis** – In-memory key-value store
- **Gunicorn** – WSGI HTTP server for production
- **Nginx** – Reverse proxy and SSL termination
- **Docker + Docker Compose** – Container orchestration
- **Jenkins** – CI/CD automation tool

---

## 🚀 Environments

### 🔧 Development

- Flask runs with `flask run` and hot-reloading
- Accessible at: `http://aws16.duckdns.org:8081/`
- Uses:
  - `docker-compose.yml`
  - `docker-compose.override.yml`
  - `nginx/dev.conf`

### ✅ Production

- Flask served via Gunicorn
- Nginx handles reverse proxy and SSL
- Accessible at: `http://aws16.duckdns.org:8082/`
- Uses:
  - `docker-compose.yml`
  - `docker-compose.prod.yml`
  - `nginx/prod.conf`

---

## 🧪 Health Checks

- Flask: checked via HTTP `curl`
- Redis: checked via `redis-cli ping`

---

## ⚙ Jenkins CI/CD Pipeline

1. **dev** branch triggers build and runs development stack.
2. If successful and approved, merge to **main**.
3. **main** branch triggers deployment to production.

### Pipeline logic

- Defined in `Jenkinsfile`
- Webhook from GitHub automatically triggers builds

---

## 🔐 Security

- Nginx in production supports HTTPS via Let's Encrypt
- Security Groups expose only necessary ports
- Jenkins secured and runs Docker without `sudo`

---

## 🗂 Directory Structure

```
flask-redis-app/
│
├── app/                    # Flask application
├── nginx/
│   ├── dev.conf            # Nginx for dev
│   └── prod.conf           # Nginx for prod
├── docker-compose.yml
├── docker-compose.override.yml
├── docker-compose.prod.yml
├── Jenkinsfile
├── Dockerfile
└── README.md               # This file
```

---

## 🧠 Tip

Never bind Nginx to port 80 if already used by system-wide Nginx or another service.
Use `sudo lsof -i :80` or `sudo netstat -tulnp | grep :80` to diagnose.

---

## 👤 Author

Automated by Jenkins | Managed by DevOps @aws16.duckdns.org
