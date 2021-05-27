defmodule Endpoints.AuthEndpoint do

  import Plug.Conn
  use Plug.Router
  plug CORSPlug, origin: ["http://localhost:4200"]
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

  post "/register" do
    registerUrl = 'http://localhost:4000/users/register'
    {email, password, firstname, lastname, role, company} =  {
      Map.get(conn.params, "email", nil),
      Map.get(conn.params, "password", nil),
      Map.get(conn.params, "firstname", nil),
      Map.get(conn.params, "lastname", nil),
      Map.get(conn.params, "role", nil),
      Map.get(conn.params, "company", nil)

    }
    body = Poison.encode!(%Register{email: email, password: password,firstname: firstname,lastname: lastname,
    role: role,company: company})
    headers = [{"Content-type", "application/json"}]
    case HTTPoison.post(registerUrl, body, headers, []) do
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

  get "/companies" do
    companiesUrl = 'http://localhost:4000/users/companies'
    body = ""
    headers = [{"Content-type", "application/json"}]

    case HTTPoison.get(companiesUrl) do
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