defmodule Endpoints.PostingEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Routes.Base, as: Base
    alias Models.Postings
    alias Models.Category
    alias Models.Application

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
        deleteUrl = "http://localhost:3000/postings"
        headers = []
        params = %{id: id}
        IO.inspect(params)
        case HTTPoison.delete(deleteUrl, headers, params) do
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
        posting_data = %Postings{postedById: postedById, postedAt: postedAt,
        deadline: deadline,
        numberOfViews: numberOfViews,
        name: name,
        description: description,
        categoryId: categoryId,
        requirements: requirements} = conn

        body = Poison.encode!(posting_data)
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

        update_data = %Postings{id: id,  deadline: deadline, name: name, description: description, 
        requirements: requirements} = conn

        body = Poison.encode!(update_data)
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