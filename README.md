# openwebrxplus-deb-builder

Build `.deb` packages for [OpenWebRX+](https://github.com/luarvique/openwebrx) and related dependencies using Docker images per distro/release.

## Overview

This repository provides one build runner:

- `./run` – wave-parallel builder with fail-fast behavior

The runner:

- Auto-start/check APT cache (`apt-cache/docker-compose.yml`)
- Build for selected distro/release tags from `docker/Dockerfile-*`
- Build for selected architectures (`amd64`, `arm64`, `armhf`)
- Write artifacts to `owrx/<distro>/<release>/<arch>`

## Requirements

- Docker + Docker Buildx
- For non-native arch builds: `qemu-user-static` on host
- Bash environment

## Quick Start

### Parallel build (default)

```sh
./run settings
./run build
```

When running inside tmux, `build` uses per-job tmux panes by default.
To force plain merged output, use:

```sh
./run build --plain
```

### Serial interactive debug mode

Use this when a build fails and you want to inspect/work inside the container interactively:

```sh
./run build-debug
```

## Commands

The `run` script exposes these commands:

- `settings` – create/edit settings file
- `build` – run parallel architecture waves
- `build --plain` – force plain merged output (no pane UI)
- `build-debug` – run serial interactive mode (`docker run -it`)
- `create` – build builder images with `docker buildx`
- `start-apt-cache` / `stop-apt-cache`

Examples:

```sh
./run build
./run build --plain
./run build-debug
./run create # if you want to build your own docker builders (otherwise mine from dockerhub will be used)
```

## Settings Files

- `run` reads: `settings.env`

Important settings:

- `ARCHITECTURES=(amd64 arm64 armhf)`
- `DISTROS=(debian-bookworm debian-trixie ... )`
- `MAKEFLAGS=-jN`
- `BUILD_*` flags (`y`/`n`) to select which packages to build
- Docker registry/image settings (`REGISTRYUSER`, `IMAGE_NAME`, `PUSH_TO_DOCKERHUB`)

## Build Model

### Default mode (`run build`)

- Runs architecture waves in order:
	1. `amd64`
	2. `arm64`
	3. `armhf`
- Within a wave, all selected distro/release jobs run concurrently
- Inside tmux: one pane per running job (job label in pane title)
- Outside tmux or with `--plain`: merged output with per-job prefix `[distro/release/arch]`
- Prefix tokens are colorized and color-stable for the whole run
- Tmux window name shows current wave (`wave-amd64`, etc.)

### Debug mode (`run build-debug`)

- Runs the same distro/release/arch matrix one container at a time
- Uses `docker run -it` for interactive terminal access
- Keeps fail-fast behavior (stops at first failing job)
- Useful for debugging failing package builds directly in the container shell

## Failure Behavior

`run build` is configured as **fail-fast**:

- If any job in the current wave fails, remaining jobs in that wave are stopped immediately
- Build exits with non-zero status
- Next waves are not started

`run build-debug` also stops at first failure, but in interactive mode so you can inspect the failing environment.

Before each wave starts, `run build` performs preflight container architecture checks (`dpkg --print-architecture`) and aborts early if requested and actual container architectures do not match.

## No-Build Smoke Test Mode

If all `BUILD_*` flags are `n`, runners still launch containers and execute setup flow (APT, env wiring), but do not compile packages.

This is useful to validate:

- container startup
- architecture scheduling
- settings mounts
- logging behavior

## Logs and Artifacts

Artifacts:

- `owrx/<distro>/<release>/<arch>/`

Parallel logs:

- `logs/run-<timestamp>-<pid>/`
- One log file per job (`<distro>-<release>-<arch>.log`)

## Creating Builder Images

If you need to build your own builder images:

```sh
./run create
```

Notes:

- Multi-arch `create` requires `PUSH_TO_DOCKERHUB=y`
- For Docker Hub push, log in first:

```sh
docker login -u <username>
```

## Troubleshooting

- **Docker/Buildx missing**: install Docker Engine + Buildx plugin
- **ARM builds failing to start**: verify `qemu-user-static`
- **APT cache issues**: restart with `./run stop-apt-cache && ./run start-apt-cache`
- **No artifacts produced**: check `BUILD_*` flags and logs in the latest `logs/run-*` directory
