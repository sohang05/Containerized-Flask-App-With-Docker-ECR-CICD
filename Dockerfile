# Stage 1: Build

FROM python:3.10-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime

FROM python:3.10-slim

WORKDIR /app

COPY --from=builder /root/.local /root/.local

COPY app/ app/

ENV PATH=/root/.local/bin:$PATH

EXPOSE 5000

CMD ["python", "app/app.py"]
