#!/usr/bin/make -f
##  
# OpenWebRX+ DEB packages builder
#  

.DEFAULT_GOAL := help

HAS_PODMAN := $(shell podman -v 2>/dev/null || false)
HAS_BUILDAH := $(shell buildah -v 2>/dev/null || false)
HAS_DOCKER := $(shell docker -v 2>/dev/null || false)
HAS_BUILDX := $(shell docker buildx version 2>/dev/null || false)

.ONESHELL:

# use 'make create DOCKER_PUSH=--push' to push to docker hub
# use 'make create DOCKER_PUSH=--load' to load to local system. BEWARE, only one ARCH can be loaded, do not use multi-arch builds with --load
DOCKER_PUSH := --push

## Targets:
.PHONY: help
## Print this help
help: checks helpmakefile

# example env file
define example_env
# Settings file for the docker-deb-builder

# What architectures are we building?
# possible values: amd64, arm64, armhf
# this variable should be a bash array in ()
ARCHITECTURES=(amd64 arm64 armhf)
#ARCHITECTURES=(amd64)
# if you want to change the DOCKER_PUSH in the Makefile to '--load', you must use only one ARCH.

# Build script to use inside the builder.
# If there are 'buildscript/[0-9]{2}-build-.*\.sh' on the host, they will be used.
# if the local build scripts are missing, then this variable should be set to url with a build script.
# this is the official OWRX+ build script
#BUILDSCRIPT=https://raw.githubusercontent.com/luarvique/openwebrx/master/buildall.sh
# this is the build script from my fork
#BUILDSCRIPT=https://raw.githubusercontent.com/0xAF/openwebrxplus/master/buildall.sh
# and if the build script fails, you will be given a shell to inspect/fix
#BUILDSCRIPT=please_fail

# Arguments to be passed to build script.
# --ask argument will ask you for every package to be build
#BUILDSCRIPT_ARGS="--ask"
# you can pass an 'env' file as argument, to setup the build script
# this file should be in './buildscript' folder
#BUILDSCRIPT_ARGS="buildscript/openwebrxplus.env"

# If you are going to compile the docker-deb-builder, you should set your username
# for docker hub and use 'docker login' command to be able to push.
# If you do not know what this is for, do not touch these variables.
REGISTRY="docker.com"
REGISTRYUSER="slechev"
IMAGE_NAME="openwebrxplus-deb-builder"

# vim: set ft=sh
endef
export example_env

# load and export all env vars
ifneq (,$(wildcard ./settings.env)) # check if file exists
    include settings.env
    export
endif


.PHONY: checks
# check for the tools
checks:
	@
	$(info OpenWebRX+ DEB packages builder make script)
	$(info )
# do we have podman/buildah
ifdef HAS_PODMAN
ifndef HAS_BUILDAH
	$(info Podman detected, but Buildah is missing. Cannot use Podman.)
else
	$(eval CAN_PODMAN = $(HAS_PODMAN), $(HAS_BUILDAH))
	$(info Podman: $(CAN_PODMAN))
endif
else
	$(info Podman: not installed.)
endif
# do we have docker/buildx
ifdef HAS_DOCKER
ifndef HAS_BUILDX
	$(info Docker detected, but BuildX is missing. Cannot use Docker.)
else
	$(eval CAN_DOCKER = $(HAS_DOCKER), $(HAS_BUILDX))
	$(info Docker: $(CAN_DOCKER))
endif
else
	$(info Docker: not installed.)
endif
# report what we have
	$(if $(CAN_PODMAN), \
		$(info Preferred builder Podman/Buildah.), \
		$(if $(CAN_DOCKER), \
			$(info Preferred builder Docker/BuildX), \
			$(error Neither Podman nor Docker is installed. Cannot continue.) \
		) \
	)
# check for settings.env
ifeq (,$(wildcard ./settings.env)) # check if file exists
	$(error settings.env file does not exist. Use 'make settings' to create and edit.)
endif
	echo Image: $(REGISTRY)/$(REGISTRYUSER)/$(IMAGE_NAME)
	echo Architectures\(bash array\): $${ARCHITECTURES}
	echo


.PHONY: helpmakefile
# print help by parsing the makefile
helpmakefile:
	@awk '/^## / \
		{ if (c) {printf "\033[1m%s\033[0m\n", c}; c=substr($$0, 4); next } \
		c && /(^[[:alpha:]][[:alnum:]_-]+:)/ \
		{printf "\033[36m%-30s\033[0m \033[1m%s\033[0m\n", $$1, c; c=0} \
		END { printf "\033[1m%s\033[0m\n", c }' $(MAKEFILE_LIST)


.PHONY: settings
## edit settings with $EDITOR or vim
settings:
	@if [ ! -f ./settings.env ]; then echo "$$example_env" > settings.env; fi
	@$${EDITOR:-vim} ./settings.env

define create_podman_builders
	@
	. ./settings.env
	echo [+] Creating builders with Podman/Buildah

	echo [+] Removing old manifest, if any...
	buildah manifest rm $${IMAGE_NAME} || true
	echo [+] Creating new manifest...
	buildah manifest create $${IMAGE_NAME}

	@for file in Dockerfile*; do
		IMAGE_TAG=$$(echo $$file | sed -e 's/^Dockerfile-//' )
		echo -e [++] Creating builders for "\e[36m$${IMAGE_TAG}\e[0m"

		for arch in "$${ARCHITECTURES[@]}"; do
			echo -e [+++] "\e[36m$$IMAGE_TAG\e[0m": create builder for "\e[36m$$arch\e[0m"
			time buildah bud \
			--tag "$${REGISTRY}/$${REGISTRYUSER}/$${IMAGE_NAME}:$${IMAGE_TAG}-$${arch}" \
			--manifest $${IMAGE_NAME} \
			--arch $${arch} \
			-f $$file \
			.
		done

		echo [++] $$IMAGE_TAG: push all arch to manifest
		buildah manifest push --all \
			$${IMAGE_NAME} \
			"docker://$${REGISTRY}/$${REGISTRYUSER}/$${IMAGE_NAME}:$${IMAGE_TAG}"
	done
endef

define create_docker_builders
	@
	. ./settings.env
	echo [+] Creating builders with Docker/BuildX
	docker buildx create --name owrxp-builder --driver docker-container --bootstrap --use --driver-opt network=host || true

	@for file in Dockerfile*; do
		IMAGE_TAG=$$(echo $$file | sed -e 's/^Dockerfile-//' )
		echo -e [++] Creating builders for "\e[36m$${IMAGE_TAG}\e[0m"

		PLATFORMS=""
		for arch in "$${ARCHITECTURES[@]}"; do
			PLATFORMS="$$PLATFORMS,linux/$$arch"
		done
		PLATFORMS=$$(echo $$PLATFORMS | cut -c2-)

		echo -e [+++] "\e[36m$$IMAGE_TAG\e[0m": create builders for "\e[36m$$PLATFORMS\e[0m"
		time docker buildx build \
		--tag "$${REGISTRYUSER}/$${IMAGE_NAME}:$${IMAGE_TAG}" \
		--platform $$PLATFORMS \
		$(DOCKER_PUSH) \
		-f $$file \
		.
	done

	docker buildx rm --keep-state owrxp-builder

endef

.PHONY: create
## Create builder images with preferred tool
create: checks
	$(if $(CAN_PODMAN), \
		$(call create_podman_builders), \
		$(if $(CAN_DOCKER), \
			$(call create_docker_builders), \
		) \
	)


## Create builder images with Podman
create_podman: checks
	$(if $(CAN_PODMAN), \
		$(call create_podman_builders), \
		$(error Cannot use Podman.) \
	)

## Create builder images with Docker, use 'make create DOCKER_PUSH=--push' to push to docker hub
create_docker: checks
	$(if $(CAN_DOCKER), \
		$(call create_docker_builders), \
		$(error Cannot use Docker.) \
	)


#=====================================================================

define build_podman
	@
	. ./settings.env
	echo [+] Building packages with Podman/Buildah
	for image in $$(podman image ls -a -n | grep $${IMAGE_NAME} | grep -v latest | awk '{print $$2}'); do
		if [ -d ./buildscript ]; then
			MNTBS="-v ./buildscript:/usr/src/buildscript"
		fi
		distro=$$(echo $$image | cut -d '-' -f 1)
		release=$$(echo $$image | cut -d '-' -f 2)
		arch=$$(echo $$image | cut -d '-' -f 3)
		echo =====================
		echo -e running "\e[36m$$distro $$release\e[0m" build for "\e[36m$$arch\e[0m"
		echo
		mkdir -p owrx/$$distro/$$release/$$arch
		time podman run -it --rm --arch $$arch \
			-v ./owrx/$$distro/$$release/$$arch:/owrx --name owrx-build-$$image \
			$$MNTBS \
			-e BUILDSCRIPT="$${BUILDSCRIPT}" \
			-e BUILDSCRIPT_ARGS="$${BUILDSCRIPT_ARGS}" \
			docker://$${REGISTRY}/$${REGISTRYUSER}/$${IMAGE_NAME}:$$image
	done
endef

define build_docker
	@
	. ./settings.env
	echo [+] Building packages with Docker/BuildX
	@for file in Dockerfile*; do
		IMAGE_TAG=$$(echo $$file | sed -e 's/^Dockerfile-//' )
		if [ -d ./buildscript ]; then
			MNTBS="-v ./buildscript:/usr/src/buildscript"
		fi
		for arch in "$${ARCHITECTURES[@]}"; do
			distro=$$(echo $${IMAGE_TAG} | cut -d '-' -f 1)
			release=$$(echo $${IMAGE_TAG} | cut -d '-' -f 2)
			echo =====================
			echo -e running "\e[36m$$distro $$release\e[0m" build for "\e[36m$$arch\e[0m"
			echo
			mkdir -p owrx/$$distro/$$release/$$arch
			time docker run -it --rm --platform linux/$$arch \
				--name owrx-build-$${IMAGE_TAG} \
				-v ./owrx/$$distro/$$release/$$arch:/owrx \
				$$MNTBS \
				-e BUILDSCRIPT="$${BUILDSCRIPT}" \
				-e BUILDSCRIPT_ARGS="$${BUILDSCRIPT_ARGS}" \
				$${REGISTRYUSER}/$${IMAGE_NAME}:$${IMAGE_TAG}
		done
	done
endef


.PHONY: build
## Build DEB packages with preferred tool
build: checks
	$(if $(CAN_PODMAN), \
		$(call build_podman), \
		$(if $(CAN_DOCKER), \
			$(call build_docker), \
		) \
	)

## Build DEB packages with Podman
build_podman: checks
	$(if $(CAN_PODMAN), \
		$(call build_podman), \
		$(error Cannot use Podman.) \
	)

## Build DEB packages with Docker
build_docker: checks
	$(if $(CAN_DOCKER), \
		$(call build_docker), \
		$(error Cannot use Docker.) \
	)





##  
## Choose a target to run
##  
