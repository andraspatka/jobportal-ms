defmodule Endpoints.RequestEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Services.Url


    @endpoint_url Application.get_env(:portal_management, :endpoint_url)
    @origin Application.get_env(:portal_management, :origin)

    plug CORSPlug, origin: @origin
    plug(:match)
    plug(:dispatch)

    #send request to become employer
    post "/" do

        auth = get_req_header(conn, "authorization")
        IO.puts("Become employer request....")
        IO.inspect(auth)
        headers = [{"Content-type", "application/json"}, {"Authorization","#{auth}"}]
        body = Poison.encode!(%{})
        url = Url.user_endp(@endpoint_url.user_request)
        case HTTPoison.post(url, body, headers) do
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
        url = Url.user_endp(@endpoint_url.user_request)
        case HTTPoison.get(url, headers) do
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
        url = Url.user_endp(@endpoint_url.user_request)
        case HTTPoison.patch(url, body, headers) do
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