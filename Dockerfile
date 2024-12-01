FROM alpine:3.20

RUN apk add cmake ninja clang lld python3

ENV CC=clang CXX=clang++

WORKDIR /work

ENTRYPOINT [ "/bin/sh" ]
