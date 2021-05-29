defmodule Endpoints.AuthEndpoint do

  import Plug.Conn
  use Plug.Router
  alias Routes.Base
  alias Models.Login
  alias Models.Register
  alias Models.Company

  @login Application.get_env(:portal_management, :login)
  @register Application.get_env(:portal_management, :register)
  @origin Application.get_env(:portal_management, :origin)
  @companies Application.get_env(:portal_management, :companies)
  plug(:match)
  plug(:dispatch)
  plug CORSPlug, origin: ["http://localhost:4200"]

  post "/login"  do
   
    { email, password } = {
      Map.get(conn.params, "email", nil),
      Map.get(conn.params, "password", nil)
    }
   
    body = Poison.encode!(%Login{email: email, password: password})
    headers = [{"Content-type", "application/json"}]
    
    case HTTPoison.post(@login, body, headers) do
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

    case HTTPoison.post(@register, body, headers, []) do
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
   
    IO.inspect(@companies)
    # case HTTPoison.get(@companies) do
    #   {:ok, response} ->
    #     conn
    #       |> put_resp_content_type("application/json")
    #       |> send_resp(200, response.body)
    #   {:not_found, response} ->
    #     conn
    #       |> put_resp_content_type("application/json")
    #       |> send_resp(404, response.body)
    #   {:error, response} ->
    #     conn
    #       |> put_resp_content_type("application/json")
    #       |> send_resp(500, response.body)
    # end
  end

  post "/companies" do

    {name, admin} =  {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "admin", nil)
    }
    body = Poison.encode!(%Company{name: name, admin: admin})
    headers = [{"Content-type", "application/json"}]

    case HTTPoison.post(@companies, body, headers) do
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