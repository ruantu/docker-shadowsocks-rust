#!/bin/env sh

DOCKER_BUILDKIT=1
docker build --target build .
docker build --target final-client --tag shadowsocks-rust-client:latest .
docker build --target final-server --tag shadowsocks-rust-server:latest .
docker image ls -a
docker image prune -f
