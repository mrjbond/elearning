defmodule BenchmarkServer.Router do
  use Plug.Router
  use Plug.ErrorHandler

  @file_name "random_bytes"

  plug(:match)
  plug(:dispatch)

  get "/bytes" do
    {rounds, conn} =
      conn
      |> fetch_query_params()
      |> get_rounds_from_query_params()

    contents = File.read!(@file_name)

    initial_hash = :crypto.hash(:sha256, contents)

    data =
      1..rounds
      |> Enum.reduce(initial_hash, fn _current, acc -> :crypto.hash(:sha256, acc) end)
      |> Base.encode64()

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, data)
  end

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    # Could use `conn.status`.
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(500, "500 Internal Server Error")
  end

  defp get_rounds_from_query_params(%{query_params: %{"rounds" => rounds}} = conn) do
    {String.to_integer(rounds), conn}
  end

  defp get_rounds_from_query_params(conn) do
    {10, conn}
  end
end
