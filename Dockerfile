# Stage 1 – Build stage for dependencies
FROM python:3.11-alpine AS builder  # Use lightweight Python base for build step

WORKDIR /app  # Set working directory inside the image

# Install build dependencies required for some Python packages (e.g., cryptography)
RUN apk add --no-cache gcc musl-dev libffi-dev

# Copy only requirements.txt to allow Docker cache to reuse if unchanged
COPY app/requirements.txt .

# Install Python dependencies into a temporary install directory
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# -------------------------------------------------------------------

# Stage 2 – Final image for running the application
FROM python:3.11-alpine  # Use minimal Python image for runtime

WORKDIR /app  # Set working directory for application

# Add a non-root user to run the app more securely
RUN adduser -D appuser

# Use the non-root user from now on
USER appuser

# Add build arguments and use them in LABELS
ARG BUILD_VERSION=unknown
LABEL maintainer="devops-team@example.com"
LABEL version="${BUILD_VERSION}"
LABEL description="Flask app with Redis + MySQL + Jenkins + Volumes"

# Copy the installed Python packages from the builder stage
COPY --from=builder /install /usr/local

# Copy the actual application code into the image
COPY app/ .

# Expose the port used by Flask in production
EXPOSE 8088

# Default command to run the app – can be overridden in docker-compose
CMD ["python", "app.py"]
