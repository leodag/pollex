defmodule Pollex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Pollex.Repo,
      # Start the Telemetry supervisor
      PollexWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Pollex.PubSub},
      {Registry, keys: :unique, name: Pollex.PollRegistry},
      # Start the Endpoint (http/https)
      PollexWeb.Endpoint
      # Start a worker by calling: Pollex.Worker.start_link(arg)
      # {Pollex.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pollex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PollexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
