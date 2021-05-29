defmodule Endpoints.StatisticsEndpoint do
    import Plug.Conn
    use Plug.Router


    @endpoint_url Application.get_env(:portal_management, :endpoint_url)

    plug(:match)
    plug(:dispatch)
    plug CORSPlug, origin: @endpoint_url.origin


    get "/" do
        auth = get_req_header(conn, "authorization")
        headers = [{"Authorization","#{auth}"}]

        case HTTPoison.get(@endpoint_url.statistics, headers) do
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


    get "/:type" do
        
      auth = get_req_header(conn, "Authorization")
      headers = [{"Authorization","#{auth}"}]
      {type} = { Map.get(conn.path_params, "type", nil) }

      case HTTPoison.get(@endpoint_url.statistics <> "/#{type}", headers) do
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