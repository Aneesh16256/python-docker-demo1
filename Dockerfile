# Stage 1: Build stage
FROM python:3.11-slim as builder

WORKDIR /app

# Create and activate virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Stage 2: Runtime stage
FROM python:3.11-slim as runtime

WORKDIR /app

# Copy only the necessary files from builder
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app/app.py .

# Set environment variables
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Run as non-root user
RUN useradd -m appuser && chown -R appuser /app
USER appuser

# Run the application
CMD ["python", "app.py"]