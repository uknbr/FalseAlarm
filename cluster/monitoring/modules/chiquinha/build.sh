#!/usr/bin/env bash
archs=(amd64 arm)
mkdir -p ./bin

for arch in ${archs[@]}
do
    env GOOS=linux GOARCH=${arch} go build -o ./bin/chiquinha_${arch}
    du -h ./bin/chiquinha_${arch}
done

docker buildx build --platform linux/amd64,linux/arm -t uknbr/florindabox-chiquinha --push .
exit $?

#wget https://github.com/docker/buildx/releases/download/v0.7.1/buildx-v0.7.1.linux-amd64
#mkdir -p ~/.docker/cli-plugins/
#mv buildx-v0.7.1.linux-amd64 ~/.docker/cli-plugins/docker-buildx
#chmod +x ~/.docker/cli-plugins/docker-buildx