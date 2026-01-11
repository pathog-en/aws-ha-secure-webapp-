# 1. Small, predictable base
FROM python:3.12-slim

# 2. Environment hygiene
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 3. Create non-root user (critical)
RUN useradd -m appuser

# 4. Set working directory
WORKDIR /app

# 5. Install system deps (keep minimal)
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 6. Copy dependency files first (build cache efficiency)
COPY app/requirements.txt ./requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

# 7. Copy application code
COPY . .

# 8. Change ownership + drop privileges
RUN chown -R appuser:appuser /app
USER appuser

# 9. Expose port (documentation, not security)
EXPOSE 8000

# 10. Healthcheck (DO NOT SKIP)
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# 11. Explicit startup command
CMD ["python", "app/main.py"]




