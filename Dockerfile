###########
# BUILDER #
###########

# pull official base image
FROM python:3.12-alpine as builder

# get UV from Astral site
COPY --from=ghcr.io/astral-sh/uv:0.5.1 /uv /bin/uv
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

# set work directory
WORKDIR /home/app

# copy the TOML files and sync the dependencies
COPY uv.lock pyproject.toml /home/app/
RUN --mount=type=cache,target=/root/.cache/uv \
	uv sync --frozen --no-install-project --no-dev

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install Ubuntu dependencies
RUN apk update \
	&& apk add python3-dev musl-dev

RUN apk update \
    && apk add postgresql-dev gcc python3-dev musl-dev \
    && apk add jpeg-dev zlib-dev libjpeg libjpeg-turbo-dev libpng-dev freetype-dev

COPY . /home/app
RUN --mount=type=cache,target=/root/.cache/uv \
	uv sync --frozen --no-dev

#########
# FINAL #
#########

# pull official base image
FROM python:3.12-alpine

# create directory for the app user
RUN mkdir -p /home/app

# copy everything from the builder and put venv in the path
COPY --from=builder /home/app /home/app
ENV PATH="/home/app/.venv/bin:$PATH"

ENTRYPOINT ["/home/app/entrypoint.sh"]

