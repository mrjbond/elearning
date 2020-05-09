defmodule KvApi.Repo do
  use Ecto.Repo,
    otp_app: :kv_api,
    adapter: Ecto.Adapters.Postgres
end
