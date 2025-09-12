FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    cmake \
    unzip \
    zlib1g-dev \
    wget \
    git

RUN apt-get update && apt-get install -y \
    llvm-12 \
    clang-12

RUN ln -s /usr/bin/clang-12 /usr/bin/clang
RUN ln -s /usr/bin/clang++-12 /usr/bin/clang++
RUN ln -s /usr/bin/llvm-config-12 /usr/bin/llvm-config
RUN ln -s /usr/bin/opt-12 /usr/bin/opt
