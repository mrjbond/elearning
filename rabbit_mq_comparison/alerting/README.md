# Alerting

An attempt at objectively assessing various RabbitMQ clients – specifically their publishing (`Producer`) capabilities.

We will bild a very simple London Underground control centre and look at the following criteria:

-   Setup
    -   Docs, developer experience
    -   Supervision
    -   Config & Defaults
    -   Logging
-   Performance (confirm mode)
-   Resilience
    -   Supervision strategies
    -   Error/Exception handling and recovery

Last updated: Sun 17 May 2020

## Table of contents

-   [Prerequisites](#prerequisites)

-   [1. Setup](#1-setup)

    -   [`get_rmq` v2.6.1](#get_rmq-v261)

        -   [Defining producers](#defining-producers)
        -   [Supervision](#supervision)
        -   [Configuration & Defaults](#configuration--defaults)
        -   [Logging](#logging)

    -   [`rabbit_mq` v0.0.19](#rabbit_mq-v0019)

        -   [Defining producers](#defining-producers-1)
        -   [Supervision](#supervision-1)
        -   [Configuration & Defaults](#configuration--defaults-1)

-   [2. Performance (confirm mode)](#2-performance-confirm-mode)

    -   [`get_rmq` v2.6.1](#get_rmq-v261-1)

        -   [Publishing 1,000 messages (random 2kB string) in parallel](#publishing-1000-messages-random-2kb-string-in-parallel)
        -   [Publishing 10,000 messages (random 2kB string) in parallel](#publishing-10000-messages-random-2kb-string-in-parallel)

    -   [`rabbit_mq` v0.0.19](#rabbit_mq-v0019-1)

        -   [Publishing 1,000 messages (random 2kB string) in parallel](#publishing-1000-messages-random-2kb-string-in-parallel-1)
        -   [Publishing 10,000 messages (random 2kB string) in parallel](#publishing-10000-messages-random-2kb-string-in-parallel-1)

## Prerequisites

-   RabbitMQ up & running
-   Routing topology set up

RabbitMQ routing topology used:

    rabbitmqadmin declare exchange name=station_updates type=direct durable=true
    rabbitmqadmin declare queue name=station_updates/westminster durable=true
    rabbitmqadmin declare binding source=station_updates destination=station_updates/westminster routing_key=westminster

## 1. Setup

### `get_rmq` v2.6.1

#### Defining producers

```elixir
defmodule Producers.GenRMQ.StationUpdatesProducer do
  @amqp_url "amqp://guest:guest@localhost:5672"
  @behaviour GenRMQ.Publisher

  def init() do
    [
      connection: @amqp_url,
      exchange: "station_updates",
    ]
  end
end
```

Now, this won't work as I already declared my exchange and **the Publisher module will implicitly try to redeclare it**.

    17:12:55.846 [error] [Elixir.Producers.GenRMQ.StationUpdatesProducer]: Terminating publisher, error_code: 406, reason: "PRECONDITION_FAILED - inequivalent arg 'type' for exchange 'station_updates' in vhost '/': received 'topic' but current is 'direct'"

    17:12:55.847 [error] GenServer Producers.GenRMQ.StationUpdatesProducer terminating
    ** (stop) exited in: :gen_server.call(#PID<0.400.0>, {:call, {:"exchange.declare", 0, "station_updates", "topic", false, true, false, false, false, []}, :none, #PID<0.388.0>}, 60000)
        ** (EXIT) shutdown: {:server_initiated_close, 406, "PRECONDITION_FAILED - inequivalent arg 'type' for exchange 'station_updates' in vhost '/': received 'topic' but current is 'direct'"}
        (stdlib 3.11.1) gen_server.erl:223: :gen_server.call/3
        (amqp 1.4.2) lib/amqp/exchange.ex:48: AMQP.Exchange.declare/4
        (gen_rmq 2.6.1) lib/publisher.ex:334: GenRMQ.Publisher.setup_publisher/1
        (gen_rmq 2.6.1) lib/publisher.ex:286: GenRMQ.Publisher.handle_info/2
        (stdlib 3.11.1) gen_server.erl:637: :gen_server.try_dispatch/4
        (stdlib 3.11.1) gen_server.erl:711: :gen_server.handle_msg/6
        (stdlib 3.11.1) proc_lib.erl:249: :proc_lib.init_p_do_apply/3
    Last message: :init
    State: %{config: [connection: "amqp://guest:guest@localhost:5672", exchange: "station_updates"], module: Producers.GenRMQ.StationUpdatesProducer}

The default type chosen is `topic`, therefore I need to re-configure my Publisher.

```elixir
defmodule Producers.GenRMQ.StationUpdatesProducer do
  @amqp_url "amqp://guest:guest@localhost:5672"
  @behaviour GenRMQ.Publisher

  def init() do
    [
      connection: @amqp_url,
      exchange: {:direct, "station_updates"},
    ]
  end
end
```

#### Supervision

As it stands, I can only start my Producer under a `Supervisor` using the somewhat verbose `child_spec` notation.

```elixir
children = [
  %{
    id: Producers.GenRMQ.StationUpdatesProducer,
    start:
      {GenRMQ.Publisher, :start_link,
        [
          Producers.GenRMQ.StationUpdatesProducer,
          [name: Producers.GenRMQ.StationUpdatesProducer]
        ]}
  }
]
```

It would have been nice to just start the child like so:

```elixir
children = [
  Producers.GenRMQ.StationUpdatesProducer
]
```

This is the resulting supervision tree.

![gen_rmq Publisher setup](assets/gen_rmq_supervision_tree.png)

Based on this diagram, it's not immediately obvious how the underlying connection is started and whether and how it's linked to the Publisher. I looked at the source code and it seems as though the connection is established "inside" the Publisher and kept in its (`GenServer`) state.

#### Configuration & Defaults

-   Publishing app id is [configurable and defaults to `:gen_rmq`](https://github.com/meltwater/gen_rmq/blob/v2.6.1/lib/publisher.ex#L51)
-   Publisher confirms are [_disabled_ by default](https://github.com/meltwater/gen_rmq/blob/v2.6.1/lib/publisher.ex#L53)
    -   Confirm timeout is [configurable and defaults to 5 seconds](https://github.com/meltwater/gen_rmq/blob/v2.6.1/lib/publisher.ex#L55)
-   Reconnection interval [is set to 5 seconds and is _not_ configurable](https://github.com/meltwater/gen_rmq/blob/v2.6.1/lib/publisher.ex#L421).

#### Logging

Lager conflicts

    17:16:00.853 [error] calling logger:remove_handler(default) failed: :error {:badmatch, {:error, {:not_found, :default}}}

### `rabbit_mq` v0.0.19

#### Defining producers

```elixir
defmodule Producers.RabbitMQ.StationUpdatesProducer do
  use RabbitMQ.Producer, exchange: "station_updates"
end
```

There is no implicit declaration of exchanges or queues.

#### Supervision

I can start my new producer under a `Supervisor` like so:

```elixir
children = [
  Producers.RabbitMQ.StationUpdatesProducer
]
```

This is the resulting supervision tree.

![rabbit_mq Publisher setup](assets/rabbit_mq_supervision_tree.png)

It's a little more involved, but I immediately see _what_ my Producer does. There is a dedicated connection, and a pool of producer workers.

#### Configuration & Defaults

TBC

## 2. Performance (confirm mode)

### `get_rmq` v2.6.1

I first need to enable publisher confirms:

```elixir
defmodule Producers.GenRMQ.StationUpdatesProducer do
  @amqp_url "amqp://guest:guest@localhost:5672"
  @behaviour GenRMQ.Publisher

  def init() do
    [
      connection: @amqp_url,
      enable_confirmations: true,
      exchange: {:direct, "station_updates"}
    ]
  end
end
```

#### Publishing 1,000 messages (random 2kB string) in parallel

```elixir
Benchmarks.run(:gen_rmq, 1_000)
```

1.  1282737μs => 1.28 seconds
2.  1156328μs => 1.16 seconds
3.  1197980μs => 1.2 seconds

#### Publishing 10,000 messages (random 2kB string) in parallel

```elixir
Benchmarks.run(:gen_rmq, 10_000)
```

1.  13136601μs => 13.14 seconds
2.  12618056μs => 12.62 seconds
3.  12816920μs => 12.82 seconds

### `rabbit_mq` v0.0.19

Publisher confirms are always enabled, so I don't need to change my Producer.

#### Publishing 1,000 messages (random 2kB string) in parallel

```elixir
Benchmarks.run(:rabbit_mq, 1_000)
```

1.  30733μs => 30.73 milliseconds
2.  31588μs => 31.59 milliseconds
3.  34636μs => 34.64 milliseconds

#### Publishing 10,000 messages (random 2kB string) in parallel

```elixir
Benchmarks.run(:rabbit_mq, 10_000)
```

1.  276470μs => 276.47 milliseconds
2.  307873μs => 307.87 milliseconds
3.  288246μs => 288.25 milliseconds
