defmodule TagzUp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TagzUpWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:tagzup, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TagzUp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: TagzUp.Finch},
      # Start a worker by calling: TagzUp.Worker.start_link(arg)
      # {TagzUp.Worker, arg},
      # Start to serve requests, typically the last entry
      TagzUpWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TagzUp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TagzUpWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
