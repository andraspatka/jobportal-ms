defmodule Endpoints.PostingEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Models.Postings
    alias Services.Url

    @endpoint_url Application.get_env(:portal_management, :endpoint_url)
    @origin Application.get_env(:portal_management, :origin)
    plug(:match)
    plug(:dispatch)
    plug CORSPlug, origin: @origin

    get "/postings" do

        auth = get_req_header(conn, "authorization")
        headers = [{"Authorization","#{auth}"}]
        url = Url.posting_endp(@endpoint_url.posting_posting)
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

    delete "/postings/:id" do
        
      auth = get_req_header(conn, "authorization")
      headers = [{"Authorization","#{auth}"}]

        {id} = {
          Map.get(conn.path_params, "id", nil)
        }

        url = Url.posting_endp(@endpoint_url.posting_posting) <> "/#{id}"

        case HTTPoison.delete(url, headers,[]) do
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

        auth = get_req_header(conn, "authorization")
        headers = [{"Content-type", "application/json"}, {"Authorization","#{auth}"}]
        url = Url.posting_endp(@endpoint_url.posting_posting)

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


    patch "/postings" do

        {id, deadline, name, description, requirements} = {
          Map.get(conn.params, "id", nil),
          Map.get(conn.params, "deadline", nil),
          Map.get(conn.params, "name", nil),
          Map.get(conn.params, "description", nil),
          Map.get(conn.params, "requirements", nil),
        }

        body = Poison.encode!(%Postings{id: id,  deadline: deadline, name: name, description: description, 
        requirements: requirements})
        auth = get_req_header(conn, "authorization")
        headers = [{"Content-type", "application/json"}, {"Authorization","#{auth}"}]
        url = Url.posting_endp(@endpoint_url.posting_posting)

        case HTTPoison.patch(url, body, headers, []) do
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