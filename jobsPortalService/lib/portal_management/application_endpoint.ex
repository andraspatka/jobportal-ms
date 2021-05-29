defmodule Endpoints.ApplicationEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Models.Apply
     
    @applications Application.get_env(:portal_management, :applications)
    @origin Application.get_env(:portal_management, :origin)
    plug(:match)
    plug(:dispatch)
    plug CORSPlug, origin: ["http://localhost:4200"]

    #apply to posting
    post "/applications" do

        {numberYearsExperience, workingExperience, education, applicationDate,
         applicantId, postingId} = {
            Map.get(conn.params, "numberYearsExperience", nil),
            Map.get(conn.params, "workingExperience", nil),
            Map.get(conn.params, "education", nil),
            Map.get(conn.params, "applicationDate", nil),
            Map.get(conn.params, "applicantId", nil),
            Map.get(conn.params, "postingId", nil)
        }

        body = Poison.encode!(%Apply{numberYearsExperience: numberYearsExperience,
        workingExperience: workingExperience,
        education: education,
        applicationDate: applicationDate,
        applicantId: applicantId,
        postingId: postingId})
        auth = get_req_header(conn, "authorization")
        headers = [{"Content-type", "application/json"}, {"Authorization","#{auth}"}]

        case HTTPoison.post(@applications, body, headers, []) do
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
        
        #fetchUrl="http://localhost:3000/applications/user/#{id}"
        auth = get_req_header(conn, "authorization")
        headers = [{"Authorization","#{auth}"}]

        url = "#{@applications}" <> "user/#{id}"
        case HTTPoison.get(url,headers) do
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
        #fetchUrl="http://localhost:3000/applications/posting/#{id}"
        auth = get_req_header(conn, "authorization")
        headers = [{"Authorization","#{auth}"}]

        url = "#{@applications}" <> "posting/#{id}"
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

    delete "/applications/:id" do
      
        {id} = {
            Map.get(conn.path_params, "id", nil)
        }
        #deleteUrl = "http://localhost:3000/applications/#{id}"
        auth = get_req_header(conn, "authorization")
        headers = [{"Authorization","#{auth}"}]

        url = "#{@applications}" <> "#{id}"
        case HTTPoison.delete(url, headers) do
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
