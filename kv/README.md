# KV

**TODO: Add description**

## Demo notes

### KV.V1

First, try running `KV.V1.loop/1` as a simple process:

```elixir
iex> pid = spawn(fn -> KV.V1.loop(%{milk: 314, honey: 42}) end)
```

Then, try sending messages to this newly spawned process:

```elixir
iex> send(pid, {:get, :milk, self()})
iex> send(pid, {:get, :honey, self()})
```

You should have received the respective replies in your (caller) process, most likely `iex`. To dequeue messages from our mailbox, we can use `receive` or we can simply `flush()`.

```elixir
iex> flush()
```

You should see the following.

```elixir
314 # The result of :get (:milk)
42 # The result of :get (:honey)
:ok # The return value of flush/0
```

Now, let's try to add a new item to our key-value store.

```elixir
iex> send(pid, {:put, :coffee, 365, self()})
```

And to retrieve it:

```elixir
iex> send(pid, {:get, :coffee, self()})
```

Now, let's run `flush()` again.

```elixir
iex> flush()
```

We will see the following.

```elixir
:ok # The result of :put
365 # The result of :get (:coffee)
:ok # The return value of flush/0
```

#### The need for monitoring

Let's try to send a message to our server that we know it won't be able to handle.

    iex> send(pid, :unknown_command)

We will immediately be told that the process crashed:

```elixir
[error] Process #PID<0.1974.0> raised an exception
** (FunctionClauseError) no function clause matching in KV.V1.handle_message/2
    (kv 0.1.0) lib/kv/kv_v1.ex:20: KV.V1.handle_message(:unknown_command, %{honey: 42, milk: 314})
    (kv 0.1.0) lib/kv/kv_v1.ex:16: KV.V1.loop/1
```

We can verify that the process is no longer alive with `Process.alive?/1`:

```elixir
iex> Process.alive?(pid)
false
```

This means we will no longer be able to send messages to it.

However, we can always start a new process. This time, let's try and _monitor_ our process – it would be great to get notified when it crashes!

For this purpose, we can use `Process.monitor/1`.

```elixir
iex> pid = spawn(fn -> KV.V1.loop(%{milk: 314, honey: 42}) end)
iex> Process.monitor(pid)
```

Now, when the process crashes, a special message will arrive in our mailbox.

```elixir
iex> send(pid, :unknown_command)
iex> flush()
{:DOWN, #Reference<0.3130631526.604504066.127220>, :process, #PID<0.1985.0>,
 {:function_clause,
  [
    {KV.V1, :handle_message, [:unknown_command, %{honey: 42, milk: 314}],
     [file: 'lib/kv/kv_v1.ex', line: 20]},
    {KV.V1, :loop, 1, [file: 'lib/kv/kv_v1.ex', line: 16]}
  ]}}
:ok
```

This, along with the ability to link processes, is what enables supervision in Erlang (and by extension Elixir).

### Tasks

To make use of such "built-in" supervision, we could use `Task`s.

First, let's start a `Task.Supervisor` as part of our main (application) supervision tree. We give it a name for convenience (`TaskSupervisor`), and from here on we can easily start and supervise `Task`s.

```elixir
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KV.Supervisor]
    Supervisor.start_link(children, opts)
  end
```

To start a new child, we can do the following.

```elixir
iex> Task.Supervisor.start_child(TaskSupervisor, KV.V1, :loop, [%{milk: 314, honey: 42}])
```

We can observe the following supervision tree.

TODO screenshot

Let's start a few more tasks:

```elixir
iex> 1..3 |> Enum.map(fn _index -> Task.Supervisor.start_child(TaskSupervisor, KV.V1, :loop, [%{milk: 314, honey: 42}]) end)
iex> Task.Supervisor.children(TaskSupervisor)
[#PID<0.202.0>, #PID<0.1221.0>, #PID<0.1222.0>, #PID<0.1223.0>]
```

Which corresponds to this updated supervision tree.

TODO screenshot

This means we now have 4 servers running in parallel!

Let's see what happens when we send an unprocessable message to one of them.

```elixir
iex> pid = Task.Supervisor.children(TaskSupervisor) |> Enum.random()
iex> send(pid, :unknown_command)
Task #PID<0.200.0> started from #PID<0.1223.0> terminating
** (FunctionClauseError) no function clause matching in KV.V1.handle_message/2
    (kv 0.1.0) lib/kv/kv_v1.ex:20: KV.V1.handle_message(:unknown_command, %{honey: 42, milk: 314})
    (kv 0.1.0) lib/kv/kv_v1.ex:16: KV.V1.loop/1
    (elixir 1.10.0) lib/task/supervised.ex:90: Task.Supervised.invoke_mfa/2
    (stdlib 3.11.1) proc_lib.erl:249: :proc_lib.init_p_do_apply/3
Function: &KV.V1.loop/1
    Args: [%{honey: 42, milk: 314}]
```

We see that the process crashed, and rightly so.

```elixir
iex> Task.Supervisor.children(TaskSupervisor)
[#PID<0.202.0>, #PID<0.1221.0>, #PID<0.1222.0>]
```

Consequently, our `Task.Supervisor` now has one less child.

To ensure our server gets restarted in case of a crash, we need to use the `restart: :permanent` policy when starting our children.

Let's restart our `iex` session and start a bunch of chilren with the updated policy:

```elixir
iex> 1..20 |> Enum.map(fn _index -> Task.Supervisor.start_child(TaskSupervisor, KV.V1, :loop, [%{milk: 314, honey: 42}], restart: :permanent) end)
iex> Task.Supervisor.children(TaskSupervisor)
[#PID<0.192.0>, #PID<0.193.0>, #PID<0.194.0>, #PID<0.195.0>, #PID<0.196.0>,
 #PID<0.197.0>, #PID<0.198.0>, #PID<0.199.0>, #PID<0.200.0>, #PID<0.201.0>,
 #PID<0.202.0>, #PID<0.203.0>, #PID<0.204.0>, #PID<0.205.0>, #PID<0.206.0>,
 #PID<0.207.0>, #PID<0.208.0>, #PID<0.209.0>, #PID<0.210.0>, #PID<0.211.0>]
```

Let's try to crash one of them again.

```elixir
iex> pid = Task.Supervisor.children(TaskSupervisor) |> Enum.random()
iex> send(pid, :unknown_command)
```

Again, we see that our process is no longer alive, however this time our `Task.Supervisor` took notice and (re)started our server as its new child.

To verify:

    iex> Task.Supervisor.children(TaskSupervisor)
    [#PID<0.192.0>, #PID<0.193.0>, #PID<0.194.0>, #PID<0.195.0>, #PID<0.196.0>,
     #PID<0.197.0>, #PID<0.198.0>, #PID<0.199.0>, #PID<0.200.0>, #PID<0.201.0>,
     #PID<0.202.0>, #PID<0.203.0>, #PID<0.204.0>, #PID<0.205.0>, #PID<0.206.0>,
     #PID<0.208.0>, #PID<0.209.0>, #PID<0.210.0>, #PID<0.211.0>, #PID<0.3752.0>]

This is what enables Erlang and Elixir projects to stay relatively clean and simple, for it encourages developers to code primarily "for the happy path".

"Thing fail" and the runtime has been designed with this in mind. Be sure to take advantage of that 😎!

### KV

#### Distribution

Let's start two named nodes:

    iex --sname foo@localhost -S mix

    iex --sname bar@localhost -S mix

To get the list of children on another node:

```elixir
task = Task.Supervisor.async({TaskSupervisor, :bar@localhost}, fn -> Supervisor.which_children(KV.Supervisor) end)
remote_children = Task.await(task)
```

Pick a random child:

```elixir
random_server = remote_children |> Enum.random() |> elem(1)
```

Retrieve a value from one of the servers on a remote node:

```elixir
KV.get(random_server, :milk)
```
