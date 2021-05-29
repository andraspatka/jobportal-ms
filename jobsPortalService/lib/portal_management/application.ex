defmodule PortalManagement.Application do
 # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: App.Worker.start_link(arg)
      # {App.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: Api.Router, options: [port: api_port]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PortalManagement.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Call environment variables here.
  defp api_port, do: Application.get_env(:portal_management, :api_port)
  #defp port, do: Application.get_env(:app, :port, 8000)
end