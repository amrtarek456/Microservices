FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    GUNICORN_CMD_ARGS="--bind 0.0.0.0:5000 --workers 2 --threads 4 --timeout 60"

WORKDIR /app

COPY requirements.txt .
RUN python -m pip install --upgrade pip setuptools wheel \
 && if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi \
 && pip install --no-cache-dir Flask==3.0.3 Werkzeug==3.0.3 Jinja2==3.1.4 itsdangerous==2.2.0 click==8.1.7 gunicorn==21.2.0

COPY . .

RUN addgroup --system app && adduser --system --ingroup app app && chown -R app:app /app
USER app

EXPOSE 5000
CMD ["gunicorn", "app.main:app"]
