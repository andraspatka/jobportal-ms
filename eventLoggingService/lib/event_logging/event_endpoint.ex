defmodule Api.EventEndpoint do
  use Plug.Router

  alias Api.Views.EventView
  alias Api.Models.Event
  alias Api.Plugs.JsonTestPlug
  alias Api.Service.Consumer

  @api_port Application.get_env(:events_management, :api_port)
  @api_host Application.get_env(:events_management, :api_host)
  @api_scheme Application.get_env(:events_management, :api_scheme)
  @queue_events Application.get_env(:events_management, :event_users_queue)
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
    {_, events} = Event.find_all(%{})

    conn
    |> put_status(200)
    |> assign(:jsonapi, events)
  end

  def consume_message do
    IO.puts("Waiting for new events....")
    Consumer.consume(@queue_events)
    wait_for_messages()
  end

  def wait_for_messages do
    receive do
      {:basic_deliver, payload, _meta} ->
        response = Poison.decode!(payload)
        IO.puts "Received #{payload}"
        type = response |> Map.get("type")
        details = response |> Map.get("details")
        id = UUID.uuid1()
        %Event{id: id, type: type, details: details, created_at: nil, updated_at: nil}
        |> Event.save
        wait_for_messages()
    end
  end

end