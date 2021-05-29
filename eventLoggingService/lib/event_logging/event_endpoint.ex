defmodule Api.EventEndpoint do
  use Plug.Router

  alias Api.Views.EventView
  alias Api.Models.Event
  alias Api.Models.JwtToken
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
    headers = get_req_header(conn, "authorization")
    header = [{"Content-type", "application/json"}]
    case headers do
      ["Bearer " <> token] ->
        body = Poison.encode!(%JwtToken{jwt: token})
        case HTTPoison.post(@token_verification, body, header) do
          {_, response} ->
            cond do
              response.status_code == 200 ->
                {_, events} = Event.find_all(%{})

                conn
                |> put_status(200)
                |> assign(:jsonapi, events)
              response.status_code == 400 -> conn
                                             |> put_status(400)
                                             |> assign(
                                                  :jsonapi,
                                                  %{body: "Token is invalid!"}
                                                )
            end
        end
    end
  end

  get "/:type",
      private: %{
        view: EventView
      }
    do
    headers = get_req_header(conn, "authorization")
    header = [{"Content-type", "application/json"}]
    case headers do
      ["Bearer " <> token] ->
        body = Poison.encode!(%JwtToken{jwt: token})
        case HTTPoison.post(@token_verification, body, header) do
          {_, response} ->
            cond do
              response.status_code == 200 ->
                {_, events} = Event.find_all(%{type: type})

                conn
                |> put_status(200)
                |> assign(:jsonapi, events)
              response.status_code == 400 -> conn
                                             |> put_status(400)
                                             |> assign(
                                                  :jsonapi,
                                                  %{body: "Token is invalid!"}
                                                )
            end
        end
    end
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
        type = response
               |> Map.get("type")
        details = response
                  |> Map.get("details")
        id = UUID.uuid1()
        %Event{id: id, type: type, details: details, created_at: nil, updated_at: nil}
        |> Event.save
        wait_for_messages()
    end
  end

end