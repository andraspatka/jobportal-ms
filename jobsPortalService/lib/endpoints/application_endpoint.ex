defmodule Endpoints.ApplicationEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Models.Application
    plug CORSPlug, origin: ["http://localhost:4200"]
    plug(:match)
    plug(:dispatch)
    #apply to posting
    post "/applications" do
        applyUrl = "http://localhost:3000/applications"

        {numberYearsExperience, workingExperience, education, applicationDate,
         applicantId, postingId} = {
            Map.get(conn.params, "numberYearsExperience", nil),
            Map.get(conn.params, "workingExperience", nil),
            Map.get(conn.params, "education", nil),
            Map.get(conn.params, "applicationDate", nil),
            Map.get(conn.params, "applicantId", nil),
            Map.get(conn.params, "postingId", nil)
        }

        body = Poison.encode!(%Application{numberYearsExperience: numberYearsExperience,
        workingExperience: workingExperience,
        education: education,
        applicationDate: applicationDate,
        applicantId: applicantId,
        postingId: postingId})

        headers = [{"Content-type", "application/json"}]

        case HTTPoison.post(applyUrl, body, headers, []) do
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


    #fetch applications for specific userId
    get "/applications/user/:id" do

        {id} = { Map.get(conn.path_params, "id", nil)}
        
        fetchUrl="http://localhost:3000/applications/user/#{id}"

        case HTTPoison.get(fetchUrl) do
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

    #fetch application for specific postingId
    get "/applications/posting/:postingId" do

        {id} = {
            Map.get(conn.path_params, "postingId", nil)
        }
        fetchUrl="http://localhost:3000/applications/posting/#{id}"

        case HTTPoison.get(fetchUrl) do
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

    delete "/applications/:id" do
        deleteUrl = "http://localhost:3000/applications"
        params = %{id: id}
        IO.inspect(params)
        case HTTPoison.delete(deleteUrl, [], params) do
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
