#!/usr/bin/env bash
archs=(amd64 arm)
mkdir -p ./bin

for arch in ${archs[@]}
do
    env GOOS=linux GOARCH=${arch} go build -o ./bin/speedtest_${arch}
    docker build --build-arg ARCH=${arch} -t uknbr/florindabox-speedtest:${arch} .
done