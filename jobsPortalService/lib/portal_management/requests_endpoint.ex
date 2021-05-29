defmodule Endpoints.RequestEndpoint do

    import Plug.Conn
    use Plug.Router


    @endpoint_url Application.get_env(:portal_management, :endpoint_url)

    plug(:match)
    plug(:dispatch)
    plug CORSPlug, origin: ["http://localhost:4200"]

    #send request to become employer
    post "/" do

        auth = get_req_header(conn, "Authorization")
        IO.puts("Become employer request....")
        IO.inspect(auth)
        headers = [{"Content-type", "application/json"}, {"Authorization","#{auth}"}]
        body = Poison.encode!(%{})
        case HTTPoison.post(@endpoint_url.request, body, headers) do
            {:ok, response} ->
              conn
                |> put_resp_content_type("application/json")
                |> send_resp(200, response.body)
            {:not_found, response} ->
              conn
                |> put_resp_content_type("application/json")
                |> send_resp(404, response.body)
            {:error, response} ->
              conn
                |> put_resp_content_type("application/json")
                |> send_resp(500, response.body)
          end
    end

    #fetch my requests

    get "/" do

        auth = get_req_header(conn, "authorization")
        headers = [{"Authorization","#{auth}"}]
        
        case HTTPoison.get(@endpoint_url.request, headers) do
            {:ok, response} ->
              conn
                |> put_resp_content_type("application/json")
                |> send_resp(200, response.body)
            {:not_found, response} ->
              conn
                |> put_resp_content_type("application/json")
                |> send_resp(404, response.body)
            {:error, response} ->
              conn
                |> put_resp_content_type("application/json")
                |> send_resp(500, response.body)
          end
    end

    patch "/" do

        {id, status } = {
            Map.get(conn.params, "id", nil),
            Map.get(conn.params, "status", nil)
        }

        body = Poison.encode!(%{id: id, status: status})
        auth = get_req_header(conn, "authorization")
        headers = [{"Content-type", "application/json"}, {"Authorization","#{auth}"}]

        case HTTPoison.patch(@endpoint_url.request, body, headers) do
          {:ok, response} ->
            conn
              |> put_resp_content_type("application/json")
              |> send_resp(200, response.body)
          {:not_found, response} ->
            conn
              |> put_resp_content_type("application/json")
              |> send_resp(404, response.body)
          {:error, response} ->
            conn
              |> put_resp_content_type("application/json")
              |> send_resp(500, response.body)
        end
    end
end