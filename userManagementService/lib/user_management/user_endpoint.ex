defmodule Api.UserEndpoint do
  use Plug.Router

  alias Api.Views.UserView
  alias Api.Models.User
  alias Api.Plugs.JsonTestPlug

  @api_port Application.get_env(:user_management, :api_port)
  @api_host Application.get_env(:user_management, :api_host)
  @api_scheme Application.get_env(:user_management, :api_scheme)

  @skip_token_verification %{jwt_skip: true}

  plug :match
  plug :dispatch
  plug JsonTestPlug
  plug Api.AuthPlug
  plug :encode_response

  defp encode_response(conn, _) do
    conn
    |>send_resp(conn.status, conn.assigns |> Map.get(:jsonapi, %{}) |> Poison.encode!)
  end

  defp is_password_correct(password_hash, password) do
    {:ok, service} = Api.Service.Auth.start_link
    Api.Service.Auth.verify_hash(service, {password, password_hash})
  end

  # Todo, fix this, fix auth
  get "/", private: %{view: UserView}  do
    params = Map.get(conn.params, "filter", %{})

    {_, users} =  User.find(params)

    conn
    |> put_status(200)
    |> assign(:jsonapi, users)
  end

  get "/:id", private: %{view: UserView}  do
    {parsedId, ""} = Integer.parse(id)

    case User.get(parsedId) do
      {:ok, user} ->

        conn
        |> put_status(200)
        |> assign(:jsonapi, user)

      :error ->
        conn
        |> put_status(404)
        |> assign(:jsonapi, %{"error" => "'user' not found"})
    end
  end

  post "/login", private: @skip_token_verification do
    {email, password} = {
      Map.get(conn.params, "email", nil),
      Map.get(conn.params, "password", nil),
    }
    IO.puts("password: #{password}")
    IO.puts("email: #{email}")

    cond do
      is_nil(email) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "email must be present!"})

      is_nil(password) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "password must be present!"})

      true ->

        case User.find(%{email: email}) do
          {:ok, user} ->
            cond do
              !is_password_correct(user.password, password) ->
                conn
                |> put_status(403)
                |> assign(:jsonapi, %{error: "password invalid!"})

            true ->
              {:ok, service} = Api.Service.Auth.start_link
              token = Api.Service.Auth.issue_token(service, %{:email => email})

              conn
              |> put_status(200)
              |> assign(:jsonapi, %{:token => token})
            :error ->
              conn
              |> put_status(500)
              |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
            end
          :error ->
            conn
            |> put_status(404)
            |> assign(:jsonapi, %{"error" => "User not found"})
        end
    end
  end

  post "/logout", private: @skip_token_verification do
    IO.puts("Called logout")
    {email, password} = {
      Map.get(conn.params, "email", nil),
      Map.get(conn.params, "password", nil),
    }

    {:ok, service} = Api.Service.Auth.start_link

    case User.find(%{email: email}) do
      {:ok, user} ->
        cond do
          !is_password_correct(user.password, password) ->
            conn
            |> put_status(403)
            |> assign(:jsonapi, %{error: "password invalid!"})

          true ->
            case Api.Service.Auth.revoke_token(service, %{:email => email}) do
              :ok ->
                conn
                |> put_status(200)
                |> assign(:jsonapi, %{"message" => "logged out: #{email}, token deleted"})
              :error ->
                conn
                |> put_status(400)
                |> assign(:jsonapi, %{"message" => "Could not log out. problem! Please log in."})

            end
          :error ->
            conn
            |> put_status(500)
            |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
        end
      :error ->
        conn
        |> put_status(404)
        |> assign(:jsonapi, %{"error" => "User not found"})
    end


  end


  post "/register", private: @skip_token_verification, private: %{view: UserView} do
    IO.puts("Registration request...")
    {:ok, service} = Api.Service.Auth.start_link
    {email, password, first_name, last_name, role, company} = {
      Map.get(conn.params, "email", nil),
      Api.Service.Auth.generate_hash(service, Map.get(conn.params, "password", nil)),
      Map.get(conn.params, "firstname", nil),
      Map.get(conn.params, "lastname", nil),
      Map.get(conn.params, "role", nil),
      Map.get(conn.params, "company", nil),
    }

    id = UUID.uuid1()

    IO.puts("Registration request: #{email}, #{first_name}, #{last_name}, #{role}, #{company}")
    cond do
      is_nil(email) ->
        IO.puts("Email missing")
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "email must be present!"})

      is_nil(password) ->
        IO.puts("password missing")
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "password must be present!"})

      is_nil(first_name) ->
        IO.puts("First name missing")
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "firstname must be present!"})

      is_nil(last_name) ->
        IO.puts("Last name missing")
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "lastname must be present!"})

      is_nil(role) ->
        IO.puts("Role missing")
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "role must be present!"})

      is_nil(company) ->
        IO.puts("Company missing")
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "company must be present!"})

      User.find(%{email: email}) != :error ->
        conn
        |> put_status(409)
        |> assign(:jsonapi, %{error: "email already exists in the db!"})


      true ->
        case %User{id: id, email: email, password: password, first_name: first_name, last_name: last_name, role: role, company: company} |> User.save do
          {:ok, createdEntry} ->
            uri = "#{@api_scheme}://#{@api_host}:#{@api_port}#{conn.request_path}/"
            #not optimal

            conn
            |> put_resp_header("location", "#{uri}#{id}")
            |> put_status(201)
            |> assign(:jsonapi, createdEntry)
          :error ->
            conn
            |> put_status(500)
            |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
        end
    end
  end
end