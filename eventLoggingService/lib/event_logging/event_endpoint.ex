defmodule Api.EventEndpoint do
  use Plug.Router

  alias Api.Views.EventView
  alias Api.Models.Event
  alias Api.Plugs.JsonTestPlug
  alias Api.Service.Publisher

  @api_port Application.get_env(:events_management, :api_port)
  @api_host Application.get_env(:events_management, :api_host)
  @api_scheme Application.get_env(:events_management, :api_scheme)
  @routing_keys Application.get_env(:events_management, :routing_keys)
  @token_verification 'http://localhost:4000/tokeninfo'

  plug :match
  plug :dispatch
  plug JsonTestPlug
  plug :encode_response

  defp encode_response(conn, _) do
    conn
    |> send_resp(
         conn.status,
         conn.assigns
         |> Map.get(:jsonapi, %{})
         |> Poison.encode!
       )
  end

  get "/",
      private: %{
        view: EventView
      }
    do
    IO.puts("Events called")
    {_, events} = Event.find_all(%{})

    conn
    |> put_status(200)
    |> assign(:jsonapi, events)
  end

end