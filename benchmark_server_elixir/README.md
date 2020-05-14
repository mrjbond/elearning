# A simple benchmark server (Elixir)

Simulates a server capable of handling IO (file-read) and controlled computation load (sha256 rounds).

The request handler performs the following operations:

1.  reads (sync, _not_ using streams) a 64kB file (random bytes); and
2.  computes a sha256 hash `n`-times (configurable via the `rounds` query parameter).

⚠️ **These tests were _not_ performed to favour one technology/platform over the other.** Rather, this is a simple exercise to help others understand where and under which contexts to use which. For example, it's well-known that Node.js is not the preferred choice for performing (heavy, or otherwise) computation at scale.

## Table of contents

-   [Demo - testing](#demo---testing)

-   [Test results](#test-results)

    -   [2,000 requests; concurrency 124; 1 hash round](#2000-requests-concurrency-124-1-hash-round)

        -   [Node.js (Express)](#nodejs-express)
        -   [Elixir (Cowboy)](#elixir-cowboy)

    -   [10,000 requests; concurrency 124; 1 hash round](#10000-requests-concurrency-124-1-hash-round)

        -   [Node.js (Express)](#nodejs-express-1)
        -   [Elixir (Cowboy)](#elixir-cowboy-1)

    -   [2,000 requests; concurrency 124; 500 hash rounds](#2000-requests-concurrency-124-500-hash-rounds)

        -   [Node.js (Express)](#nodejs-express-2)
        -   [Elixir (Cowboy)](#elixir-cowboy-2)

    -   [500 requests; concurrency 124; 10,000 hash rounds](#500-requests-concurrency-124-10000-hash-rounds)

        -   [Node.js (Express)](#nodejs-express-3)
        -   [Elixir (Cowboy)](#elixir-cowboy-3)

## Demo - testing

You may need to [increase your File Descriptor Limit](https://docs.riak.com/riak/kv/latest/using/performance/open-files-limit/index.html):

Also see the below links;

-   <https://docs.riak.com/riak/kv/latest/using/performance/erlang/index.html#warning-messages>
-   <https://elixirforum.com/t/getting-emfile-even-thou-ulimit-is-set-and-erl-max-ports-set-to-65536/15799>
-   <https://www.slideshare.net/petegamache/real-world-elixir-deployment>
-   <https://hexdocs.pm/mix/Mix.Tasks.Release.html>

Use `:erlang.system_info(:port_limit)` to verify.

## Test results

Using [ab](https://httpd.apache.org/docs/2.4/programs/ab.html) on macOS Catalina (10.15.4), MacBook Pro (16-inch, 2019):

-   Processor: 2.4 GHz 8-Core Intel Core i9;
-   Memory: 64 GB 2667 MHz DDR4

### 2,000 requests; concurrency 124; 1 hash round

ℹ️ Finding: With no computation _and_ a relatively high number of requests, Node.js throughput is approximately 50% lower than that of Elixir.

#### Node.js (Express)

```bash
ab -n 2000 -c 124 'http://127.0.0.1:3000/bytes?rounds=1'

Server Software:        Express
Server Hostname:        127.0.0.1
Server Port:            3000

Document Path:          /bytes?rounds=1
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   2.764 seconds
Complete requests:      2000
Failed requests:        0
Total transferred:      488000 bytes
HTML transferred:       88000 bytes
Requests per second:    723.69 [#/sec] (mean)
Time per request:       171.343 [ms] (mean)
Time per request:       1.382 [ms] (mean, across all concurrent requests)
Transfer rate:          172.44 [Kbytes/sec] received
```

#### Elixir (Cowboy)

```bash
ab -n 2000 -c 124 'http://127.0.0.1:4000/bytes?rounds=1'

Server Software:        Cowboy
Server Hostname:        127.0.0.1
Server Port:            4000

Document Path:          /bytes?rounds=1
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   1.422 seconds
Complete requests:      2000
Failed requests:        0
Total transferred:      496000 bytes
HTML transferred:       88000 bytes
Requests per second:    1406.39 [#/sec] (mean)
Time per request:       88.169 [ms] (mean)
Time per request:       0.711 [ms] (mean, across all concurrent requests)
Transfer rate:          340.61 [Kbytes/sec] received
```

### 10,000 requests; concurrency 124; 1 hash round

ℹ️ Finding: With no computation _and_ increased number of requests, Node.js throughput remains (more or less) the same, while Elixir throughput degrades by roughly 30%.

#### Node.js (Express)

```bash
ab -n 10000 -c 124 'http://127.0.0.1:3000/bytes?rounds=1'

Server Software:        Express
Server Hostname:        127.0.0.1
Server Port:            3000

Document Path:          /bytes?rounds=1
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   13.492 seconds
Complete requests:      10000
Failed requests:        0
Total transferred:      2440000 bytes
HTML transferred:       440000 bytes
Requests per second:    741.19 [#/sec] (mean)
Time per request:       167.299 [ms] (mean)
Time per request:       1.349 [ms] (mean, across all concurrent requests)
Transfer rate:          176.61 [Kbytes/sec] received
```

#### Elixir (Cowboy)

```bash
ab -n 10000 -c 124 'http://127.0.0.1:4000/bytes?rounds=1'

Server Software:        Cowboy
Server Hostname:        127.0.0.1
Server Port:            4000

Document Path:          /bytes?rounds=1
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   20.030 seconds
Complete requests:      10000
Failed requests:        0
Total transferred:      2480000 bytes
HTML transferred:       440000 bytes
Requests per second:    499.26 [#/sec] (mean)
Time per request:       248.367 [ms] (mean)
Time per request:       2.003 [ms] (mean, across all concurrent requests)
Transfer rate:          120.91 [Kbytes/sec] received
```

### 2,000 requests; concurrency 124; 500 hash rounds

ℹ️ Finding: With _some_ computation _and_ a relatively high number of requests, Elixir throughput remains (more or less) the same, while Node.js throughput degrades by approximately 60%.

#### Node.js (Express)

```bash
ab -n 2000 -c 124 'http://127.0.0.1:3000/bytes?rounds=500'

Server Software:        Express
Server Hostname:        127.0.0.1
Server Port:            3000

Document Path:          /bytes?rounds=500
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   3.937 seconds
Complete requests:      2000
Failed requests:        0
Total transferred:      488000 bytes
HTML transferred:       88000 bytes
Requests per second:    508.01 [#/sec] (mean)
Time per request:       244.089 [ms] (mean)
Time per request:       1.968 [ms] (mean, across all concurrent requests)
Transfer rate:          121.05 [Kbytes/sec] received
```

#### Elixir (Cowboy)

```bash
ab -n 2000 -c 124 'http://127.0.0.1:4000/bytes?rounds=500'

Server Software:        Cowboy
Server Hostname:        127.0.0.1
Server Port:            4000

Document Path:          /bytes?rounds=500
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   1.432 seconds
Complete requests:      2000
Failed requests:        0
Total transferred:      496000 bytes
HTML transferred:       88000 bytes
Requests per second:    1396.60 [#/sec] (mean)
Time per request:       88.787 [ms] (mean)
Time per request:       0.716 [ms] (mean, across all concurrent requests)
Transfer rate:          338.24 [Kbytes/sec] received
```

### 500 requests; concurrency 124; 10,000 hash rounds

ℹ️ Finding: With computation significantly increased, even with a small number of requests, Node.js throughput degrades **significantly** (likely more than 100%), while Elixir throughput only degrades slightly (around 20%).

⚠️ The actual percentage might differ slightly.

#### Node.js (Express)

```bash
ab -n 500 -c 124 'http://127.0.0.1:3000/bytes?rounds=10000'

Server Software:        Express
Server Hostname:        127.0.0.1
Server Port:            3000

Document Path:          /bytes?rounds=10000
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   14.868 seconds
Complete requests:      500
Failed requests:        0
Total transferred:      122000 bytes
HTML transferred:       22000 bytes
Requests per second:    33.63 [#/sec] (mean)
Time per request:       3687.145 [ms] (mean)
Time per request:       29.735 [ms] (mean, across all concurrent requests)
Transfer rate:          8.01 [Kbytes/sec] received
```

#### Elixir (Cowboy)

```bash
ab -n 500 -c 124 'http://127.0.0.1:4000/bytes?rounds=10000'

Server Software:        Cowboy
Server Hostname:        127.0.0.1
Server Port:            4000

Document Path:          /bytes?rounds=10000
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   0.447 seconds
Complete requests:      500
Failed requests:        0
Total transferred:      124000 bytes
HTML transferred:       22000 bytes
Requests per second:    1118.60 [#/sec] (mean)
Time per request:       110.853 [ms] (mean)
Time per request:       0.894 [ms] (mean, across all concurrent requests)
Transfer rate:          270.91 [Kbytes/sec] received
```
