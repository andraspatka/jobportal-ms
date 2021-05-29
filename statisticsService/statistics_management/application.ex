defmodule StatisticsManagement.Application do

  use Application

  @impl true
  def start(_type, _args) do

    children = [
      # Starts a worker by calling: UserManagement.Worker.start_link(arg)
      # {UserManagement.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: Api.Router, options: [port: api_port]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StatisticsManagement.Supervisor]
    Supervisor.start_link(children, opts)

    #Api.Service.Publisher.start_link
  end

  defp api_port, do: Application.get_env(:statistics_management, :api_port)
end