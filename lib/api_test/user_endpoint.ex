defmodule Api.UserEndpoint do
  use Plug.Router

  alias Api.Views.UserView
  alias Api.Models.User
  alias Api.Plugs.JsonTestPlug

  @api_port Application.get_env(:api_test, :api_port)
  @api_host Application.get_env(:api_test, :api_host)
  @api_scheme Application.get_env(:api_test, :api_scheme)

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

  # Todo, fix this, fix auth
  get "/", private: @skip_token_verification, private: %{view: UserView}  do
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

  post "/login" do
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
            password_hash = user.password
            {:ok, service} = Api.Service.Auth.start_link
            cond do
              !Api.Service.Auth.verify_hash(service, {password, password_hash}) ->
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

  post "/logout" do
    IO.puts("Called logout")
    {email, password} = {
      Map.get(conn.params, "email", nil),
      Map.get(conn.params, "password", nil),
    }

    {:ok, service} = Api.Service.Auth.start_link

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
  end


  post "/register", private: %{view: UserView} do
    IO.puts("Registration request...")
    {:ok, service} = Api.Service.Auth.start_link
    password_hash = Api.Service.Auth.generate_hash(service, Map.get(conn.params, "password", nil))
    {username, email, id, password} = {
      Map.get(conn.params, "username", nil),
      Map.get(conn.params, "email", nil),
      Map.get(conn.params, "id", nil),
      password_hash
    }

    IO.puts("Registration request: #{username}, #{email}, #{id}, #{password}")
    cond do
      is_nil(username) ->
        IO.puts("Username missing")
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "username must be present!"})

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

      is_nil(id) ->
        IO.puts("id missing")
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "id must be present!"})

      User.find(%{email: email}) != :error ->
        conn
        |> put_status(409)
        |> assign(:jsonapi, %{error: "email already exists in the db!"})


      true ->
        case %User{username: username, email: email, password: password, id: id} |> User.save do
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
