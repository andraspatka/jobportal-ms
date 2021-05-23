defmodule Endpoints.CategoryEndpoint do

    get "/categories" do
        getCategoriesUrl = "http://localhost:3000/categories"

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
end