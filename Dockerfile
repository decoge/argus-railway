FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Railway injects PORT (usually 8080). Keep a fallback for local runs.
ENV PORT=8080

# Web terminal basic auth (set these in Railway variables)
ENV USERNAME=argus
ENV PASSWORD=change-me

# Upstream source (wrapper repo approach)
ENV ARGUS_REPO=https://github.com/jasonxtn/argus.git
ENV ARGUS_REF=main

WORKDIR /app

# Base utilities + tini
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget git tini bash \
  && rm -rf /var/lib/apt/lists/*

# Install ttyd (web terminal)
RUN wget -qO /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 \
  && chmod +x /usr/local/bin/ttyd

# Clone Argus from main (as requested)
RUN git clone --depth 1 --branch "${ARGUS_REF}" "${ARGUS_REPO}" /app/argus

WORKDIR /app/argus

# Install Argus dependencies + Argus itself
# requirements.txt exists upstream and includes cmd2 (your missing module)
RUN pip install --no-cache-dir -r requirements.txt \
 && pip install --no-cache-dir -e .

# Create results dir (good target for a Railway Volume mount)
RUN mkdir -p /app/argus/results

EXPOSE 8080

ENTRYPOINT ["/usr/bin/tini","--"]

# Start ttyd and try to launch Argus; if Argus exits, drop to a shell so you can debug
CMD ["/bin/bash","-lc", "\
/usr/local/bin/ttyd --writable -i 0.0.0.0 -p ${PORT} -c ${USERNAME}:${PASSWORD} \
/bin/bash -lc 'argus || python -m argus || (echo \"Argus failed. Dropping to shell...\"; exec bash)' \
"]
