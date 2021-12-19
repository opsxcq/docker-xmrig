# XMRig container

[![Docker Pulls](https://img.shields.io/docker/pulls/strm/xmrig.svg?style=plastic)](https://hub.docker.com/r/strm/xmrig/)

XMRig is a high performance Monero (XMR) CPU miner originally based on
cpuminer-multi with heavy optimizations/rewrites and removing a lot of legacy
code, since version 1.0.0 completely rewritten from scratch on C++.

## Usage

Bellow an example usage for a **2 core** system (see the `-t 2` parameter) named
**strm-monero-01** (using the password field to set the miner name with `-p Miner01`).

```
docker run --restart unless-stopped --name miner -d --read-only -p 9901:9901 -m 50M -c 512 strm/xmrig \
           --api-worker-id strm-monero-01 --http-host 0.0.0.0 --http-port 9901 \
           --http-access-token SECRET --http-no-restricted -o pool.supportxmr.com:443 \
           -u 89hN2EgDGhu3hq9KB5NyWr1Kpr7czdYF6Tzob1wpzwg4bkLNU9ubNFrLv65cmE249nGydESohbatFVJZDduT6x1LCBt1DYR \
           -k --tls -p strm-worker-01
```

## JSON Configuration

The preferable way to configure it is using a json, use [this
website](https://xmrig.com/wizard#start) as a wizard to create your JSON
configuration.

```json
{
    "api": {
        "worker-id": "strm-monero-01"
    },
    "http": {
        "enabled": true,
        "host": "0.0.0.0",
        "port": 9901,
        "access-token": "SECRET",
        "restricted": false
    },
    "autosave": true,
    "cpu": true,
    "opencl": false,
    "cuda": false,
    "pools": [
        {
            "url": "pool.supportxmr.com:443",
            "user": "89hN2EgDGhu3hq9KB5NyWr1Kpr7czdYF6Tzob1wpzwg4bkLNU9ubNFrLv65cmE249nGydESohbatFVJZDduT6x1LCBt1DYR",
            "pass": "strm-worker-01",
            "keepalive": true,
            "tls": true
        }
    ]
}
```

## Web interface for workers

[The worker web interface](http://workers.xmrig.info/) can be accessed here and
has an intuitive interface on how to add workers and monitor them.
