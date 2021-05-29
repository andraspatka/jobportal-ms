defmodule Endpoints.EventsEnpoint do

    import Plug.Conn
    use Plug.Router
    plug(:match)
    plug(:dispatch)

    post "/" do
        sendRequestToBecomeEmployer = "http://localhost:4000/requests"

        auth = get_req_header(conn, "Authorization")
        IO.puts("Become employer request....")
        IO.inspect(auth)
        headers = [{"Content-type", "application/json"}, {"Authorization","#{auth}"}]
        body = Poison.encode!(%{})
        case HTTPoison.post(sendRequestToBecomeEmployer, body, headers) do
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