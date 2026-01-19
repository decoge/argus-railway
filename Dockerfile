FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Railway sets PORT automatically on deploy; keep a fallback for local runs
ENV PORT=7681
ENV USERNAME=argus
ENV PASSWORD=argus

WORKDIR /app

# System deps (common recon tooling + runtime basics)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget git tini \
    bash \
    dnsutils \
    iputils-ping \
    traceroute \
    whois \
    nmap \
  && rm -rf /var/lib/apt/lists/*

# Install ttyd (web terminal)
RUN wget -qO /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 \
  && chmod +x /usr/local/bin/ttyd

# Install Python deps first for better Docker layer caching
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the project
COPY . /app

# Ensure results dir exists (and is a good Volume mount target)
RUN mkdir -p /app/results

EXPOSE 7681

ENTRYPOINT ["/usr/bin/tini","--"]

# Web terminal -> runs "python -m argus" inside the browser
CMD ["/bin/bash","-lc","/usr/local/bin/ttyd --writable -i 0.0.0.0 -p ${PORT} -c ${USERNAME}:${PASSWORD} /bin/bash -lc 'python -m argus'"]
