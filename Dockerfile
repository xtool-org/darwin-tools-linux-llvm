FROM alpine:3.20

RUN apk add cmake ninja clang lld python3 git patch

ENV CC=clang CXX=clang++

COPY build.sh /work/build.sh
COPY patches /work/patches
COPY llvm-project /work/llvm-project

# revert https://github.com/swiftlang/llvm-project/pull/8119
RUN patch -p1 -d /work/llvm-project < /work/patches/lld-support-macho-files.patch

WORKDIR /work

ENTRYPOINT [ "/bin/sh" ]
