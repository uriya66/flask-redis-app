# Use official Python 3.10 image as base
FROM python:3.10

# Set the working directory inside the container
WORKDIR /app

# Copy only requirements first (for caching purposes)
COPY app/requirements.txt .

# Install Python dependencies
RUN pip install -r requirements.txt

# Copy the entire application code
COPY app/ .

# Expose the Flask app port
EXPOSE 8088

# Default command to run the Flask app in development (can be overridden in prod)
CMD ["python", "app.py"]

