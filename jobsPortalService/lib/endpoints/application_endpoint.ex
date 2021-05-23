defmodule Endpoints.ApplicationEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Routes.Base, as: Base
    alias Models.Postings
    alias Models.Category
    alias Models.Application
    
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

        fetchUrl="http://localhost:3000/applications/user"
        params = %{id: id}
        IO.inspect(params)
        case HTTPoison.get(fetchUrl,[],params) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
              conn
              |> put_status(200)
              |> assign(:jsonapi, body)
            {:not_found, %HTTPoison.Response{status_code: 404}} ->
              conn
              |> put_status(404)
              |> assign(:jsonapi, %{"not found" => "not found"})
            {:error, %HTTPoison.Error{reason: reason}} ->
              conn
              |> put_status(500)
              |> assign(:jsonapi, %{"error" => "internal erro"})
        end
    end

    #fetch application for specific postingId
    get "/applications/posting/:postingId" do
        fetchUrl="http://localhost:3000/applications/posting/"

        params = %{id: postingId}
        IO.inspect(params)
        case HTTPoison.get(fetchUrl,[],params) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
              conn
              |> put_status(200)
              |> assign(:jsonapi, body)
            {:not_found, %HTTPoison.Response{status_code: 404}} ->
              conn
              |> put_status(404)
              |> assign(:jsonapi, %{"not found" => "not found"})
            {:error, %HTTPoison.Error{reason: reason}} ->
              conn
              |> put_status(500)
              |> assign(:jsonapi, %{"error" => "internal erro"})
        end
    end

    delete "/applications/:id" do
        deleteUrl = "http://localhost:3000/applications"
        params = %{id: id}
        IO.inspect(params)
        case HTTPoison.delete(deleteUrl, [], params) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
              conn
              |> put_status(200)
              |> assign(:jsonapi, body)
            {:not_found, %HTTPoison.Response{status_code: 404}} ->
              conn
              |> put_status(404)
              |> assign(:jsonapi, %{"not found" => "not found"})
            {:error, %HTTPoison.Error{reason: reason}} ->
              conn
              |> put_status(500)
              |> assign(:jsonapi, %{"error" => "internal erro"})
        end
    end
end
