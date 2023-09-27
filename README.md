# dccd

[![Shellcheck](https://github.com/loganmarchione/dccd/actions/workflows/main.yml/badge.svg)](https://github.com/loganmarchione/dccd/actions/workflows/main.yml)

Bash tool for Docker Compose that does Continous Deployment (DCCD)

## Overview

I run a small Kubernetes cluster at home where I use [Renovate](https://github.com/renovatebot/renovate) for dependency management and [Flux](https://github.com/fluxcd/flux2) for continuous deployment.

Flux has spoiled me and I've found nothing like it for my small Docker Compose setup (the stuff that isn't on K8s yet). I know that [Portainer Business Edition](https://www.portainer.io/gitops-automation) does this, but I didn't want to have to rely on Portainer (even if they allow a certain number of free Business Edition licenses). 

DCCD is a bash script that is meant to run via crontab. It checks the specified repo and branch for changes, compares the commits on the remote and local repos, and updates the local repo as needed.

## Requirements

You'll obviously need to have `git` and `docker compose` installed.

## Usage
