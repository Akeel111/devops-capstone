FROM python:3.13-slim AS builder

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


FROM python:3.13-slim

WORKDIR /app

COPY --from=builder /install /usr/local

COPY app/ .

EXPOSE 5000

CMD ["python", "app.py"]