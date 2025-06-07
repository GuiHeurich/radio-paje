defmodule RadioBackend.Repo do
  use Ecto.Repo,
    otp_app: :radio_backend,
    adapter: Ecto.Adapters.Postgres
end
