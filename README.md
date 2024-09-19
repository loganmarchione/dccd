# dccd

[![Shellcheck](https://github.com/loganmarchione/dccd/actions/workflows/main.yml/badge.svg)](https://github.com/loganmarchione/dccd/actions/workflows/main.yml)

Bash tool for Docker Compose that does Continous Deployment (DCCD)

## Overview

I run a small Kubernetes cluster at home where I use [Renovate](https://github.com/renovatebot/renovate) for dependency management and [Flux](https://github.com/fluxcd/flux2) for continuous deployment. Flux has spoiled me, but I've found nothing like it for my small Docker Compose setup (the stuff that isn't on K8s yet).

DCCD is a bash script that is meant to run via crontab. It checks the specified repo and branch for changes, compares the commits on the remote and local repos, and if necessary, updates the local repo and redeploys your Docker Compose applications.

## Requirements

You'll obviously need to have `git` and `docker compose` installed.

Docker Compose files will need to be named `docker-compose.yml`, `docker-compose.yaml`, `compose.yml` or `compose.yaml`.

The script will redeploy Docker Compose files if it finds the remote repo has changed. Git is the source of truth.
If graceful mode is set, it will only restart the containers that need to be redeployed. It uses `docker compose --dry-run` to check if a container needs to be redeployed.

## Usage

The script is meant to run via crontab. The example below runs every 30th minute (i.e., XX:00 and XX:30).

```
*/30 * * * * /path/to/dccd.sh -b master -d /path/to/git_repo -g -l /tmp/dccd.txt -p -x ignore_this_directory
```

Usage examples are below.

```
    Usage: ./dccd.sh [OPTIONS]

    Options:
      -b <name>       Specify the remote branch to track (default: main)
      -d <path>       Specify the base directory of the git repository (required)
      -g              Graceful, only restart containers that will be recreated
      -h              Show this help message
      -l <path>       Specify the path to the log file (default: /tmp/dccd.log)
      -p              Specify if you want to prune docker images (default: don't prune)
      -x <path>       Exclude directories matching the specified pattern (relative to the base directory)
      
    Example: /path/to/dccd.sh -b master -d /path/to/git_repo -g -l /tmp/dccd.txt -p -x ignore_this_directory
```

## Alternatives

* What about [Portainer](https://github.com/portainer/portainer)? Portainer Business Edition does [gitops](https://www.portainer.io/gitops-automation), but I'm trying to remove my dependency on Portainer.
* What about [Watchtower](https://github.com/containrrr/watchtower)? Watchtower only works if the image tag is `latest`, and it checks for updates against a container image repo directly (e.g., DockerHub), not against Docker Compose files in a git repo.
* What about [Harbormaster](https://gitlab.com/stavros/harbormaster)? This comes close, but Harbormaster needs a specific configuration and the directory structure of the Docker Compose files has to be setup a specific way.
