defmodule Server.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Logger, log: :debug)

  plug(:match)
  plug(:dispatch)

  get "/hello" do
    %Plug.Conn{query_params: %{"name" => name}} = fetch_query_params(conn)

    name = String.downcase(name)

    greeting =
      if name === "bob" do
        "Yo, Bobby Love!"
      else
        "Hello, #{String.capitalize(name)}!"
      end

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, greeting)
  end

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(500, "500 Internal Server Error")
  end
end
