defmodule Endpoints.CategoryEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Models.Category
    alias Services.Url
    @endpoint_url Application.get_env(:portal_management, :endpoint_url)
    @origin Application.get_env(:portal_management, :origin)
    
    plug CORSPlug,  origin: @origin
    plug(:match)
    plug(:dispatch)

    get "/categories" do

        auth = get_req_header(conn, "authorization")
        headers = [{"Authorization","#{auth}"}]
        url = Url.posting_endp(@endpoint_url.posting_categories)

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

    post "/categories" do

        {name} = { Map.get(conn.params, "name", nil) }
        auth = get_req_header(conn, "authorization")
        body = Poison.encode!(%Category{name: name})
        headers = [{"Content-type", "application/json"}, {"Authorization","#{auth}"}]
        url = Url.posting_endp(@endpoint_url.posting_categories)
        case HTTPoison.post(url, body, headers, []) do
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