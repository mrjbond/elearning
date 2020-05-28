defmodule Server.Router.V2 do
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Logger, log: :debug)

  plug(:match)
  plug(:dispatch)

  get "/hello" do
    conn
    |> fetch_query_params()
    |> process(:greeting)
    |> send_resp()
  end

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(500, "500 Internal Server Error")
  end

  defp process(%Plug.Conn{query_params: %{"name" => name}} = conn, :greeting) do
    greeting =
      name
      |> String.downcase()
      |> build_greeting()

    conn
    |> put_resp_content_type("text/plain")
    |> resp(200, greeting)
  end

  defp build_greeting("bob") do
    "Yo, Bobby Love!"
  end

  defp build_greeting("jo" <> _rest) do
    "A true Johnny-on-the-spot!"
  end

  defp build_greeting(name) do
    "Hello, #{String.capitalize(name)}!"
  end
end
