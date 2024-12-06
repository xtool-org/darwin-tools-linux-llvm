FROM alpine:3.20

RUN apk add cmake ninja clang lld python3 git patch

ENV CC=clang CXX=clang++

COPY build.sh /work/build.sh

WORKDIR /work

ENTRYPOINT [ "/bin/sh" ]
