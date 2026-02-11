FROM python:3.12-slim

RUN apt-get update && apt-get upgrade -y
RUN pip install --no-cache-dir "poetry>=1.8,<2.0"

COPY ./pyproject.toml ./pd3f /app/

RUN mkdir /uploads

WORKDIR /app
RUN poetry config virtualenvs.create false
# poetry does not leverage Docker caching right now
RUN poetry install --without dev --no-interaction --no-root

ENV FLASK_APP=/app/app.py
