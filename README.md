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

## FAILED TO APPLY MSR MOD, HASHRATE WILL BE LOW

TL;DR, It won't be that bad,

Machine configuration
```
 * ABOUT        XMRig/6.16.2 gcc/5.4.0
 * LIBS         libuv/1.42.0 OpenSSL/1.1.1l hwloc/2.5.0
 * HUGE PAGES   supported
 * 1GB PAGES    disabled
 * CPU          AMD Ryzen 7 2700X Eight-Core Processor (1) 64-bit AES
                L2:4.0 MB L3:16.0 MB 8C/16T NUMA:1
 * MEMORY       22.5/31.4 GB (72%)
                DIMM_A1: 16 GB DDR4 @ 1067 MHz F4-3600C19-16GVRB
                DIMM_B1: 16 GB DDR4 @ 1067 MHz F4-3600C19-16GVRB
 * MOTHERBOARD  ASUSTeK COMPUTER INC. - ROG STRIX B450-I GAMING
 * DONATE       1%
 * ASSEMBLY     auto:ryzen
 * POOL #1      pool.supportxmr.com:443 algo auto
 * COMMANDS     hashrate, pause, resume, results, connection
 * HTTP API     0.0.0.0:9901 
 * OPENCL       disabled
 * CUDA         disabled
```

Resulting hashrate inside a docker container

```
[2021-12-19 18:08:00.577]  miner    speed 10s/60s/15m 4194.0 4149.3 n/a H/s max 4556.2 H/s
|    CPU # | AFFINITY | 10s H/s | 60s H/s | 15m H/s |
|        0 |        0 |   553.7 |   525.9 |     n/a |
|        1 |        1 |   551.0 |   527.3 |     n/a |
|        2 |        2 |   547.7 |   524.1 |     n/a |
|        3 |        3 |   557.2 |   532.8 |     n/a |
|        4 |        4 |   512.4 |   513.2 |     n/a |
|        5 |        5 |   505.4 |   509.5 |     n/a |
|        6 |        6 |   507.8 |   513.4 |     n/a |
|        7 |        7 |   510.1 |   511.7 |     n/a |
|        - |        - |  4245.4 |  4157.9 |     n/a |
```

Which is about the same as running it outside of the container with MSR hacks.
Another online source [can be checked
here](https://www.betterhash.net/AMD-Ryzen-7-2700X-Eight-Core-Processor-mining-profitability-15521.html).


#### What is MSR (Model-specific register) ?

A model-specific register (MSR) is any of various control registers in the x86
instruction set used for debugging, program execution tracing, computer
performance monitoring, and toggling certain CPU features.

The script for performance [tuning for randomx can be found
here](https://raw.githubusercontent.com/xmrig/xmrig/dev/scripts/randomx_boost.sh).

If we inspect the contents we have

```bash
#!/bin/sh -e

MSR_FILE=/sys/module/msr/parameters/allow_writes

if test -e "$MSR_FILE"; then
	echo on > $MSR_FILE
else
	modprobe msr allow_writes=on
fi

if grep -E 'AMD Ryzen|AMD EPYC' /proc/cpuinfo > /dev/null;
	then
	if grep "cpu family[[:space:]]:[[:space:]]25" /proc/cpuinfo > /dev/null;
		then
			echo "Detected Zen3 CPU"
			wrmsr -a 0xc0011020 0x4480000000000
			wrmsr -a 0xc0011021 0x1c000200000040
			wrmsr -a 0xc0011022 0xc000000401500000
			wrmsr -a 0xc001102b 0x2000cc14
			echo "MSR register values for Zen3 applied"
		else
			echo "Detected Zen1/Zen2 CPU"
			wrmsr -a 0xc0011020 0
			wrmsr -a 0xc0011021 0x40
			wrmsr -a 0xc0011022 0x1510000
			wrmsr -a 0xc001102b 0x2000cc16
			echo "MSR register values for Zen1/Zen2 applied"
		fi
elif grep "Intel" /proc/cpuinfo > /dev/null;
	then
		echo "Detected Intel CPU"
		wrmsr -a 0x1a4 0xf
		echo "MSR register values for Intel applied"
else
	echo "No supported CPU detected"
fi
```

Considering the case for Zen3 CPUs, the headers mean the following, it can be
checked [online
here](https://elixir.bootlin.com/linux/latest/source/arch/x86/include/asm/msr-index.h#L457).

```C
#define MSR_AMD64_LS_CFG 0xc0011020
#define MSR_AMD64_IC_CFG 0xc0011021
#define MSR_AMD64_DC_CFG 0xc0011022
#define MSR_AMD64_CU_CFG3 0xc001102b
```

[This
patch](https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/commit/?h=x86/misc&id=a7e1f67ed29f0c339e2aa7483d13b085127566ab)
states the following:


```
author	Borislav Petkov <bp@suse.de>	2020-06-10 21:37:49 +0200
committer	Borislav Petkov <bp@suse.de>	2020-06-25 10:39:02 +0200
commit	a7e1f67ed29f0c339e2aa7483d13b085127566ab (patch)
tree	10b7e9527a98dce6e5a008d2c99603dc12a2af05
parent	b3a9e3b9622ae10064826dccb4f7a52bd88c7407 (diff)
download	tip-a7e1f67ed29f0c339e2aa7483d13b085127566ab.tar.gz
x86/msr: Filter MSR writesx86-misc-2020-08-03
Add functionality to disable writing to MSRs from userspace. Writes can
still be allowed by supplying the allow_writes=on module parameter. The
kernel will be tainted so that it shows in oopses.

Having unfettered access to all MSRs on a system is and has always been
a disaster waiting to happen. Think performance counter MSRs, MSRs with
sticky or locked bits, MSRs making major system changes like loading
microcode, MTRRs, PAT configuration, TSC counter, security mitigations
MSRs, you name it.

This also destroys all the kernel's caching of MSR values for
performance, as the recent case with MSR_AMD64_LS_CFG showed.

Another example is writing MSRs by mistake by simply typing the wrong
MSR address. System freezes have been experienced that way.

In general, poking at MSRs under the kernel's feet is a bad bad idea.

So log writing to MSRs by default. Longer term, such writes will be
disabled by default.

If userspace still wants to do that, then proper interfaces should be
defined which are under the kernel's control and accesses to those MSRs
can be synchronized and sanitized properly.

[ Fix sparse warnings. ]
Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Tested-by: Sean Christopherson <sean.j.christopherson@intel.com>
Link: https://lkml.kernel.org/r/20200612105026.GA22660@zn.tnic
```
