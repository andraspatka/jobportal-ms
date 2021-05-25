defmodule Endpoints.CategoryEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Models.Category
    plug CORSPlug, origin: ["http://localhost:4200"]
    plug(:match)
    plug(:dispatch)
    get "/categories" do
        getCategoriesUrl = "http://localhost:3000/categories"

        case HTTPoison.get(getCategoriesUrl) do
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