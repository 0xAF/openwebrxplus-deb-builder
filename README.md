# openwebrxplus-deb-builder
DEB packages builder for OpenWebRX+  
Build .deb packages for [OpenWebRX+](https://github.com/luarvique/openwebrx) and its dependencies using Docker/Podman.  
To use this repo, you need `make` package installed.  
To build arm platforms, you need `qemu-user-static` package installed.  
Start by cloning this repo.

## usage
To see the help:
```sh
make
```

## create/edit settings
You will need settings file in first place:
```sh
make settings
```

## building DEB packages for selected platforms
If you want to build DEB packages, this should be enough.
```sh
make build
```
Then you will find your .deb packages in `./owrx/<distro>/<release>/<arch>` folder.

This will use my prepared builders from docker hub and will build the debs for all distro/release/arch combination I've prepared. (The `Dockerfile-*` shows which distro/release combinations are supported).
Default architectures are AMD64(X86_64), ARM64, ARMv7(ARMHF). If you want to disable some architectures, use `make settings`.

## create builder image for selected platforms in settings
To create your builder image:
```sh
make create
```

## docker
If you want to publish your builder to docker hub you need to login first:
```sh
docker login -u <username>
```

## podman
To create/use the builders with podman, you might need to login to docker.io first:
```sh
podman login docker.io
```

