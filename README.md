# openwebrxplus-deb-builder
DEB packages builder for OpenWebRX+  
Build .deb packages for [OpenWebRX+](https://github.com/luarvique/openwebrx) and it's dependencies using Docker/Podman.  
To build arm platforms, you need `qemu-user-static` package instaled.

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
If you want to build DEB packages only, this should be enough.
It will use my prepared builder from docker hub.
```sh
make build
```

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

