FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Railway injects PORT (usually 8080)
ENV PORT=8080

# ttyd basic auth (set in Railway)
ENV USERNAME=argus
ENV PASSWORD=change-me

# Upstream Argus source
ENV ARGUS_REPO=https://github.com/jasonxtn/argus.git
ENV ARGUS_REF=main

WORKDIR /app

# System deps:
# - Required for modules: whois, ping(+ipv6), nmblookup, ssh-keyscan
# - Plus common runtime utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget git tini bash \
    whois \
    iputils-ping \
    samba-common-bin \
    openssh-client \
    dnsutils \
  && rm -rf /var/lib/apt/lists/*

# Install ttyd (web terminal)
RUN wget -qO /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 \
  && chmod +x /usr/local/bin/ttyd

# Clone Argus from main
RUN git clone --depth 1 --branch "${ARGUS_REF}" "${ARGUS_REPO}" /app/argus

WORKDIR /app/argus

# Install Python deps + Argus
RUN pip install --no-cache-dir -r requirements.txt \
 && pip install --no-cache-dir -e .

# Persistent output directory (mount Railway Volume here)
RUN mkdir -p /app/argus/results

EXPOSE 8080

ENTRYPOINT ["/usr/bin/tini","--"]

# Start ttyd; keep shell alive if Argus exits
CMD ["/bin/bash","-lc", "\
/usr/local/bin/ttyd --writable -i 0.0.0.0 -p ${PORT} -c ${USERNAME}:${PASSWORD} \
/bin/bash -lc 'argus || python -m argus || (echo \"Argus failed. Dropping to shell...\"; exec bash)' \
"]
