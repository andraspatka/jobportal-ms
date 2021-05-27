defmodule Endpoints.CategoryEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Models.Category
    plug CORSPlug, origin: ["http://localhost:4200"]
    plug(:match)
    plug(:dispatch)
    get "/categories" do
        getCategoriesUrl = "http://localhost:3000/categories"
        auth = get_req_header(conn, "authorization")
        headers = [{"Authorization","#{auth}"}]
        case HTTPoison.get(getCategoriesUrl,headers) do
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

        postCategoriesUrl = "http://localhost:3000/categories"
        {name} = { Map.get(conn.params, "name", nil) }
        auth = get_req_header(conn, "authorization")
        body = Poison.encode!(%Category{name: name})
        headers = [{"Content-type", "application/json"}, {"Authorization","#{auth}"}]
        case HTTPoison.post(postCategoriesUrl, body, headers, []) do
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