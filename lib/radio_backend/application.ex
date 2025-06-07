defmodule RadioBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RadioBackendWeb.Telemetry,
      RadioBackend.Repo,
      {DNSCluster, query: Application.get_env(:radio_backend, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RadioBackend.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RadioBackend.Finch},
      # Start a worker by calling: RadioBackend.Worker.start_link(arg)
      # {RadioBackend.Worker, arg},
      # Start to serve requests, typically the last entry
      RadioBackendWeb.Endpoint,
      RadioBackend.Scheduler.Server,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RadioBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RadioBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
