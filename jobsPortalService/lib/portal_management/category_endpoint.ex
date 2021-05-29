defmodule Endpoints.CategoryEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Models.Category
        
    @categories Application.get_env(:portal_management, :categories)
    @origin Application.get_env(:portal_management, :origin)

    plug(:match)
    plug(:dispatch)
    plug CORSPlug,  origin: ["http://localhost:4200"]

    get "/categories" do

        auth = get_req_header(conn, "authorization")
        headers = [{"Authorization","#{auth}"}]

        case HTTPoison.get(@categories, headers) do
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

        case HTTPoison.post(@categories, body, headers, []) do
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