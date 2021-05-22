defmodule Endpoints.AuthEndpoint do

  import Plug.Conn
  use Plug.Router
  alias Routes.Base
  alias Models.Login
  alias Models.Register
  alias Models.Company
  plug(:match)
  plug(:dispatch)

  # @mock_data [%{"id" => 1, "title" => "Hello"}, %{"id" => 2, "title" => "world!"}]

  post "/login"  do
    loginUrl =  'http://localhost:4000/users/login'
    { email, password } = {
        Map.get(conn.params, "email", nil),
        Map.get(conn.params, "password", nil)
    }
    body = Poison.encode!(%Login{email: email, password: password})
    headers = [{"Content-type", "application/json"}]
    
    case HTTPoison.post(loginUrl, body, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
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

  post "register" do
    registerUrl = 'http://localhost:4000/users/register'

    register_data= %Register{email: email, password: password, firstname: firstname, 
    lastname: lastname, role: role, company: company} = conn

    body = Poison.encode!(register_data)
    headers = [{"Content-type", "application/json"}]

    case HTTPoison.post(registerUrl, body, headers, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
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

  get "/companies" do
    companiesUrl = 'http://localhost:4000/users/companies'
    body = ""
    headers = [{"Content-type", "application/json"}]

    case HTTPoison.get(companiesUrl) do
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

  # defp message do
  #   %{
  #     status: "OK",
  #     body: "Hello World"
  #   }
  # end

  # get "/" do
  #   send(conn, 200, @mock_data)
  # end

  # get "/" do
  #   conn
  #   |> put_resp_content_type("application/json")
  #   |> send_resp(200, Poison.encode!(message()))
  # end
end