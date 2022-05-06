FROM python:3.9-alpine

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /requirements.txt
COPY ./entrypoint.sh /entrypoint.sh

RUN apk add --no-cache mariadb-connector-c-dev bash jq
RUN apk add --update --no-cache mysql-client
RUN apk add --update --no-cache --virtual .tmp-build-deps \
	gcc libc-dev linux-headers mysql-dev
RUN pip install -r /requirements.txt

RUN apk del .tmp-build-deps

RUN mkdir /app
WORKDIR /app
COPY ./app /app

RUN adduser -D py

USER py
