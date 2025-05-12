# Stage 1 – Build Python dependencies
FROM python:3.11-alpine AS builder

WORKDIR /app

# Install build dependencies (for wheels compilation)
RUN apk add --no-cache gcc musl-dev libffi-dev

# Copy only requirements file for layer caching
COPY app/requirements.txt .

# Install Python packages
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# Stage 2 – Runtime image
FROM python:3.11-alpine

WORKDIR /app

# Copy installed packages from builder stage
COPY --from=builder /install /usr/local

# Copy application code only
COPY app/ .

# Expose Flask app port (prod: 8088 / dev: overridden)
EXPOSE 8088

# Default command (can be overridden by docker-compose)
CMD ["python", "app.py"]

