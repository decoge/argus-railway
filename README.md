# Argus on Railway (Web Terminal)
[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/argus?referralCode=decoge&utm_medium=integration&utm_source=template&utm_campaign=argus)

This repository provides a **Railway-ready wrapper** for running **Argus**, an interactive OSINT and reconnaissance framework, in a **secure browser-based terminal** using `ttyd`.

All Argus modules work **out of the box** — required system tools are preinstalled, and no additional configuration is needed beyond setting a username and password.

> ⚠️ **Legal notice**  
> Argus is intended for **authorized security testing and research only**.  
> You are responsible for complying with all applicable laws and rules of engagement.

## ✨ Features

- 🖥️ Browser-based interactive terminal (no SSH required)
- 🔐 HTTP Basic Auth (USERNAME / PASSWORD)
- 🧰 All Argus modules work out of the box
- 📦 Uses upstream **Argus `main` branch**
- 💾 Optional persistent storage for results
- 🚀 One-click deploy on Railway

## 🧱 What’s Included

This image installs **all external system tools** required by modules in `argus/modules`, including:

- `whois`
- `ping` (IPv4 + IPv6)
- `nmblookup`
- `ssh-keyscan`

## 🚀 Deploy on Railway

### 1. Deploy Railway template
[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/argus?referralCode=decoge&utm_medium=integration&utm_source=template&utm_campaign=argus)

[Railway](https://railway.com/deploy/argus?referralCode=decoge&utm_medium=integration&utm_source=template&utm_campaign=argus) will automatically detect the Dockerfile.

### 2. Set required environment variables

Only **two variables are required**:

| Variable  | Description |
|---------|-------------|
| `USERNAME` | Choose a login username for the web terminal |
| `PASSWORD` | Choose a login password for the web terminal |

> ⚠️ Use a **strong password** — this is a remote shell.
