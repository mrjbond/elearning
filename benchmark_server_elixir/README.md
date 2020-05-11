# BenchmarkServer

**TODO: Add description**

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

```bash
ab -n 2000 -c 124 'http://127.0.0.1:3000/bytes?rounds=1'
```

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

```bash
ab -n 2000 -c 124 'http://127.0.0.1:3000/bytes?rounds=500'
```

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

===

```bash
ab -n 2000 -c 124 'http://127.0.0.1:4000/bytes?rounds=1'
```

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

===

```bash
ab -n 10000 -c 124 'http://127.0.0.1:3000/bytes?rounds=1'
```

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

===

```bash
ab -n 10000 -c 124 'http://127.0.0.1:4000/bytes?rounds=1'
```

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

===

```bash
ab -n 2000 -c 124 'http://127.0.0.1:4000/bytes?rounds=500'
```

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

===

```bash
ab -n 5000 -c 124 'http://127.0.0.1:3000/bytes?rounds=500'
```

Server Software:        Express
Server Hostname:        127.0.0.1
Server Port:            3000

Document Path:          /bytes?rounds=500
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   10.642 seconds
Complete requests:      5000
Failed requests:        0
Total transferred:      1220000 bytes
HTML transferred:       220000 bytes
Requests per second:    469.82 [#/sec] (mean)
Time per request:       263.928 [ms] (mean)
Time per request:       2.128 [ms] (mean, across all concurrent requests)
Transfer rate:          111.95 [Kbytes/sec] received

===

```bash
ab -n 5000 -c 124 'http://127.0.0.1:4000/bytes?rounds=500'
```

Server Software:        Cowboy
Server Hostname:        127.0.0.1
Server Port:            4000

Document Path:          /bytes?rounds=500
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   5.681 seconds
Complete requests:      5000
Failed requests:        0
Total transferred:      1240000 bytes
HTML transferred:       220000 bytes
Requests per second:    880.10 [#/sec] (mean)
Time per request:       140.894 [ms] (mean)
Time per request:       1.136 [ms] (mean, across all concurrent requests)
Transfer rate:          213.15 [Kbytes/sec] received

===

```bash
ab -n 2500 -c 124 'http://127.0.0.1:3000/bytes?rounds=1000'
```

Server Software:        Express
Server Hostname:        127.0.0.1
Server Port:            3000

Document Path:          /bytes?rounds=1000
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   8.320 seconds
Complete requests:      2500
Failed requests:        0
Total transferred:      610000 bytes
HTML transferred:       110000 bytes
Requests per second:    300.49 [#/sec] (mean)
Time per request:       412.657 [ms] (mean)
Time per request:       3.328 [ms] (mean, across all concurrent requests)
Transfer rate:          71.60 [Kbytes/sec] received

===

```bash
ab -n 2500 -c 124 'http://127.0.0.1:4000/bytes?rounds=1000'
```

Server Software:        Cowboy
Server Hostname:        127.0.0.1
Server Port:            4000

Document Path:          /bytes?rounds=1000
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   2.294 seconds
Complete requests:      2500
Failed requests:        0
Total transferred:      620000 bytes
HTML transferred:       110000 bytes
Requests per second:    1089.68 [#/sec] (mean)
Time per request:       113.794 [ms] (mean)
Time per request:       0.918 [ms] (mean, across all concurrent requests)
Transfer rate:          263.91 [Kbytes/sec] received

===

```bash
ab -n 5000 -c 124 'http://127.0.0.1:3000/bytes?rounds=1000'
```

Server Software:        Express
Server Hostname:        127.0.0.1
Server Port:            3000

Document Path:          /bytes?rounds=1000
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   16.433 seconds
Complete requests:      5000
Failed requests:        0
Total transferred:      1220000 bytes
HTML transferred:       220000 bytes
Requests per second:    304.26 [#/sec] (mean)
Time per request:       407.547 [ms] (mean)
Time per request:       3.287 [ms] (mean, across all concurrent requests)
Transfer rate:          72.50 [Kbytes/sec] received

===

```bash
ab -n 5000 -c 124 'http://127.0.0.1:4000/bytes?rounds=1000'
```

Server Software:        Cowboy
Server Hostname:        127.0.0.1
Server Port:            4000

Document Path:          /bytes?rounds=1000
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   6.017 seconds
Complete requests:      5000
Failed requests:        0
Total transferred:      1240000 bytes
HTML transferred:       220000 bytes
Requests per second:    831.00 [#/sec] (mean)
Time per request:       149.218 [ms] (mean)
Time per request:       1.203 [ms] (mean, across all concurrent requests)
Transfer rate:          201.26 [Kbytes/sec] received

===

```bash
ab -n 2500 -c 124 'http://127.0.0.1:3000/bytes?rounds=2500'
```

Server Software:        Express
Server Hostname:        127.0.0.1
Server Port:            3000

Document Path:          /bytes?rounds=2500
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   18.960 seconds
Complete requests:      2500
Failed requests:        0
Total transferred:      610000 bytes
HTML transferred:       110000 bytes
Requests per second:    131.85 [#/sec] (mean)
Time per request:       940.438 [ms] (mean)
Time per request:       7.584 [ms] (mean, across all concurrent requests)
Transfer rate:          31.42 [Kbytes/sec] received

===

```bash
ab -n 2500 -c 124 'http://127.0.0.1:4000/bytes?rounds=2500'
```

Server Software:        Cowboy
Server Hostname:        127.0.0.1
Server Port:            4000

Document Path:          /bytes?rounds=2500
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   2.138 seconds
Complete requests:      2500
Failed requests:        0
Total transferred:      620000 bytes
HTML transferred:       110000 bytes
Requests per second:    1169.57 [#/sec] (mean)
Time per request:       106.022 [ms] (mean)
Time per request:       0.855 [ms] (mean, across all concurrent requests)
Transfer rate:          283.26 [Kbytes/sec] received

===

```bash
ab -n 5000 -c 124 'http://127.0.0.1:3000/bytes?rounds=5000'
```

Server Software:        Server
Server Hostname:        127.0.0.1
Server Port:            3000

Document Path:          /bytes?rounds=5000
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   75.274 seconds
Complete requests:      5000
Failed requests:        0
Total transferred:      1220000 bytes
HTML transferred:       220000 bytes
Requests per second:    66.42 [#/sec] (mean)
Time per request:       1866.793 [ms] (mean)
Time per request:       15.055 [ms] (mean, across all concurrent requests)
Transfer rate:          15.83 [Kbytes/sec] received

===

```bash
ab -n 5000 -c 124 'http://127.0.0.1:4000/bytes?rounds=5000'
```

Server Software:        Cowboy
Server Hostname:        127.0.0.1
Server Port:            4000

Document Path:          /bytes?rounds=5000
Document Length:        44 bytes

Concurrency Level:      124
Time taken for tests:   6.469 seconds
Complete requests:      5000
Failed requests:        0
Total transferred:      1240000 bytes
HTML transferred:       220000 bytes
Requests per second:    772.91 [#/sec] (mean)
Time per request:       160.434 [ms] (mean)
Time per request:       1.294 [ms] (mean, across all concurrent requests)
Transfer rate:          187.19 [Kbytes/sec] received

===

```bash
ab -n 500 -c 124 'http://127.0.0.1:3000/bytes?rounds=10000'
```

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

===

```bash
ab -n 500 -c 124 'http://127.0.0.1:4000/bytes?rounds=10000'
```

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
