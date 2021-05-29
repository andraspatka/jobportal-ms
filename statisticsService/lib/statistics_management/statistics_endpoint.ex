defmodule StatisticsManagement.StatisticsEnpoint do

    import Plug.Conn
    use Plug.Router
    plug(:match)
    plug(:dispatch)

    @events_url Application.get_env(:statistics_management, :events_url)

    get "/" do

        auth = get_req_header(conn, "Authorization")
        headers = [{"Authorization","#{auth}"}]
        
        case HTTPoison.get(@events_url, headers) do
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

      case HTTPoison.get(@events_url <> "/#{type}", headers) do
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