FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ENV PORT=7681
ENV USERNAME=argus
ENV PASSWORD=change-me

# Pin a commit or tag for reproducibility (recommended)
ENV ARGUS_REF=main
ENV ARGUS_REPO=https://github.com/jasonxtn/argus.git

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget git tini bash \
  && rm -rf /var/lib/apt/lists/*

RUN wget -qO /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 \
  && chmod +x /usr/local/bin/ttyd

# Pull Argus source at build time
RUN git clone --depth 1 --branch "${ARGUS_REF}" "${ARGUS_REPO}" /app/argus

WORKDIR /app/argus
RUN pip install --no-cache-dir -e .

RUN mkdir -p /app/argus/results

EXPOSE 7681
ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/bin/bash","-lc", "\
/usr/local/bin/ttyd --writable -i 0.0.0.0 -p ${PORT} -c ${USERNAME}:${PASSWORD} \
/bin/bash -lc 'argus || python -m argus || (echo \"Argus failed. Dropping to shell...\"; exec bash)' \
"]
