defmodule Endpoints.PostingEndpoint do

    import Plug.Conn
    use Plug.Router
    alias Routes.Base, as: Base

    get "/postings" do

        getPostingUrl = ""
        case HTTPoison.get(getPostingUrl, body, headers, []) do
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
        params
        case HTTPoison.delete(deleteUrl, headers, ) do
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