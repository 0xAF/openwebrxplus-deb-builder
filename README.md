# openwebrxplus-deb-builder
DEB packages builder for OpenWebRX+  
Build .deb packages for [OpenWebRX+](https://github.com/luarvique/openwebrx) and its dependencies using Docker.  
To build arm platforms, you need `qemu-user-static` package installed.  
Start by cloning this repo.

## usage
To see the help:
```sh
./run
```

## create/edit settings
You will need settings file in first place:
```sh
./run settings
```

## building DEB packages for selected platforms
If you want to build DEB packages, this should be enough.
```sh
./run build
```
Then you will find your .deb packages in `./owrx/<distro>/<release>/<arch>` folder.

This will use my prepared builders from docker hub and will build the debs for all distro/release/arch combination I've prepared. (The `docker/Dockerfile-*` shows which distro/release combinations are supported).  
Default architectures are AMD64(X86_64), ARM64, ARMv7(ARMHF). If you want to disable some architectures, use `./run settings`.

## create builder image for selected platforms in settings
NOTE: You do not have to create the buidler image. I've uploaded already prepared images in docker hub.  
To create your builder image:
```sh
./run create
```

## docker
If you've decided to create your docker builders, you might want to publish them to docker hub.  
If you want to publish your builder to docker hub you need to login first:
```sh
docker login -u <username>
```
