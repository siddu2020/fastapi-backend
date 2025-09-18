# syntax=docker/dockerfile:1
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.11-slim AS runner
WORKDIR /app
ENV PYTHONPATH=/app \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1
RUN groupadd --gid 1001 fastapi && \
    useradd --uid 1001 --gid fastapi --shell /bin/bash --create-home fastapi
COPY --from=builder /root/.local /home/fastapi/.local
ENV PATH=/home/fastapi/.local/bin:$PATH
USER fastapi
COPY . .
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000')"
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]