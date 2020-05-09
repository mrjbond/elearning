# KvApi

To start your Phoenix server:

  * Setup the project with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Init

Create a new app:

```
mix phx.new kv_api --no-webpack --no-html
```

Generate the controller, views, and context for a JSON resource:

```
mix phx.gen.json Animals Animal animals name:string number_of_legs:integer
```

Define `docker-compose.yaml`:

```
version: '3.1'

services:

  db:
    image: postgres
    restart: always
    environment:
      POSTGRES_PASSWORD: postgres
    ports:
      - '5432:5432'
```

Create the DB:

```
mix ecto.create
```

Run migrations:

```
mix ecto.migrate
```

Run the server:

```
iex -S mix phx.server
```

cURL:

```
curl http://localhost:4000/api/animals
curl -d '{"animal":{"name":"cat","number_of_legs":4}}' -H "content-type: application/json" http://localhost:4000/api/animals
curl http://localhost:4000/api/animals
```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
