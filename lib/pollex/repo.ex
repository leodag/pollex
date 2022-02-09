defmodule Pollex.Repo do
  use Ecto.Repo,
    otp_app: :pollex,
    adapter: Ecto.Adapters.Postgres
end
