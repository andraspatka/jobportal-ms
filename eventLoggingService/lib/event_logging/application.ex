defmodule EventsManagement.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ets.new(:applications, [:bag, :public, :named_table])

    children = [
      # Starts a worker by calling: ApiTest.Worker.start_link(arg)
      # {ApiTest.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: Api.Router, options: [port: api_port]},
      {Mongo, [name: :mongo, database: db, pool_size: 2]},
      {Api.Service.Publisher, app_id: :events_management},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EventsManagement.Supervisor]
    Supervisor.start_link(children, opts)

    #    Api.Service.Publisher.start_link()
  end

  defp api_port, do: Application.get_env(:events_management, :api_port)
  defp db, do: Application.get_env(:events_management, :db_db)
end
