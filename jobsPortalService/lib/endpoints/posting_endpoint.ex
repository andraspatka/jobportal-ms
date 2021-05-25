defmodule Endpoints.PostingEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Models.Postings
    plug CORSPlug, origin: ["http://localhost:4200"]
    plug(:match)
    plug(:dispatch)

    get "/postings" do
        getPostingUrl = "http://localhost:3000/postings"
        case HTTPoison.get(getPostingUrl) do
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

    delete "/postings/:id" do
        
        headers = []
        {id} = {
          Map.get(conn.path_params, "id", nil)
        }
        
        deleteUrl = "http://localhost:3000/postings/#{id}"

        case HTTPoison.delete(deleteUrl, headers,[]) do
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

    post "/postings" do

        addUrl = "http://localhost:3000/postings"

        {postedById, postedAt, deadline, numberOfViews, name, description, 
        categoryId, requirements}  = {
            Map.get(conn.params, "postedById", nil),
            Map.get(conn.params, "postedAt", nil),
            Map.get(conn.params, "deadline", nil),
            Map.get(conn.params, "numberOfViews", nil),
            Map.get(conn.params, "name", nil),
            Map.get(conn.params, "description", nil),
            Map.get(conn.params, "categoryId", nil),
            Map.get(conn.params, "requirements", nil)
        }

        body = Poison.encode!( %Postings{postedById: postedById, postedAt: postedAt,
        deadline: deadline,
        numberOfViews: numberOfViews,
        name: name,
        description: description,
        categoryId: categoryId,
        requirements: requirements})

        headers = [{"Content-type", "application/json"}]

        case HTTPoison.post(addUrl, body, headers, []) do
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


    patch "/postings" do
        updateUrl="http://localhost:3000/postings"

        {id, deadline, name, description, requirements} = {
          Map.get(conn.params, "id", nil),
          Map.get(conn.params, "deadline", nil),
          Map.get(conn.params, "name", nil),
          Map.get(conn.params, "description", nil),
          Map.get(conn.params, "requirements", nil),
        }

        body = Poison.encode!(%Postings{id: id,  deadline: deadline, name: name, description: description, 
        requirements: requirements})
        headers = [{"Content-type", "application/json"}]


        case HTTPoison.patch(updateUrl, body, headers, []) do
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