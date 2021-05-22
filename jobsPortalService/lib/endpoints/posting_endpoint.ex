defmodule Endpoints.PostingEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Routes.Base, as: Base
    alias Models.Postings
    alias Models.Category
    alias Models.Application

    get "/postings" do
        getPostingUrl = ""
        case HTTPoison.get(getPostingUrl) do
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


    delete "/postings/:id" do
        deleteUrl = ""
        headers = []
        params = %{id: id}
        IO.inspect(params)
        case HTTPoison.delete(deleteUrl, headers, params) do
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

    post "/postings" do
        addUrl = ""
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
              |> assign(:jsonapi, %{"error" => "internal error"})
        end
    end


    patch "/postings" do
        updateUrl=""

        update_data = %Postings{id: id,  deadline: deadline, name: name, description: description, 
        requirements: requirements} = conn

        body = Poison.encode!(update_data)
        headers = [{"Content-type", "application/json"}]


        case HTTPoison.post(updateUrl, body, headers, []) do
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
              |> assign(:jsonapi, %{"error" => "internal error"})
        end
    end

    get "/categories" do
        getCategoriesUrl = ""

        case HTTPoison.get(getCategoriesUrl) do
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

    #apply to posting
    post "/applications" do
        applyUrl = ""

        application_data = %Application{numberYearsExperience: numberYearsExperience,
        workingExperience: workingExperience,
        education: education,
        applicationDate: applicationDate,
        applicantId: applicantId,
        postingId: postingId} = conn

        body = Poison.encode!(application_data)
        headers = [{"Content-type", "application/json"}]

        case HTTPoison.post(applyUrl, body, headers, []) do
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
              |> assign(:jsonapi, %{"error" => "internal error"})
        end
    end


    #fetch applications for specific userId
    get "/applications/user/:id" do
        fetchUrl=""
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
        fetchUrl=""
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
        deleteUrl = ""
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