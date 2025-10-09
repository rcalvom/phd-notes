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

RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.8.11/z3-4.8.11-x64-glibc-2.31.zip \
    && unzip z3-4.8.11-x64-glibc-2.31.zip \
    && mv z3-4.8.11-x64-glibc-2.31 /opt/z3 \
    && ln -s /opt/z3/bin/z3 /usr/local/bin/z3

ENV Z3_DIR=/opt/z3

RUN ln -s /usr/bin/clang-12 /usr/bin/clang
RUN ln -s /usr/bin/clang++-12 /usr/bin/clang++
RUN ln -s /usr/bin/llvm-config-12 /usr/bin/llvm-config
RUN ln -s /usr/bin/opt-12 /usr/bin/opt

