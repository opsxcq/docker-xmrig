FROM debian:9.2

LABEL maintainer "opsxcq@strm.sh"

LABEL update "2018/10/18"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    cmake \
    build-essential \
    libuv1-dev \
    libmicrohttpd-dev \
    libssl-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone https://github.com/xmrig/xmrig.git && \
    cd xmrig && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    cp xmrig /bin && \
    rm -Rf /src

RUN useradd --system --uid 666 -M --shell /usr/sbin/nologin miner
USER miner

ENTRYPOINT ["xmrig"]

