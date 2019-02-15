FROM debian:9.2

LABEL maintainer "opsxcq@strm.sh"

LABEL update "2018/10/18"

WORKDIR /src
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    cmake \
    build-essential \
    libuv1-dev \
    libmicrohttpd-dev \
    libssl-dev \
    && \
    git clone https://github.com/xmrig/xmrig.git && \
    cd xmrig && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    cp xmrig /bin && \
    rm -Rf /src && \
    apt-get purge -y git cmake build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --system --uid 666 -M --shell /usr/sbin/nologin miner
USER miner

ENTRYPOINT ["xmrig"]

