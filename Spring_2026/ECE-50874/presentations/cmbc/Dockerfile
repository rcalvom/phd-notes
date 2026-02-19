FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        make \
        gcc \
        gcc-multilib \
        bash-completion \
        build-essential \
        libc6-dev \
        python3.10 \
        python3-pip \
        && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/diffblue/cbmc/releases/download/cbmc-6.6.0/ubuntu-22.04-cbmc-6.6.0-Linux.deb && \
    dpkg -i ubuntu-22.04-cbmc-6.6.0-Linux.deb && \
    rm ubuntu-22.04-cbmc-6.6.0-Linux.deb

RUN python3 -m pip install --no-cache-dir cbmc-viewer

RUN useradd -ms /bin/bash dev
USER dev
WORKDIR /home/dev
