defmodule Api.UserEndpoint do
  use Plug.Router

  alias Api.Views.UserView
  alias Api.Models.User
  alias Api.Plugs.JsonTestPlug
  alias Api.Encrypt

  @api_port Application.get_env(:api_test, :api_port)
  @api_host Application.get_env(:api_test, :api_host)
  @api_scheme Application.get_env(:api_test, :api_scheme)

  plug :match
  plug :dispatch
  plug JsonTestPlug
  plug :encode_response




  defp encode_response(conn, _) do
    conn
    |>send_resp(conn.status, conn.assigns |> Map.get(:jsonapi, %{}) |> Poison.encode!)
  end

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

  post "/login", private: %{view: UserView} do
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
            cond do
              !Encrypt.check(password, password_hash) ->
                conn
                |> put_status(403)
                |> assign(:jsonapi, %{error: "password invalid!"})

            true ->
              conn
              |> put_status(200)
              |> assign(:jsonapi, user)
            :error ->
              conn
              |> put_status(500)
              |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
            end
        end
    end
  end


  post "/register", private: %{view: UserView} do
    password_hash = Encrypt.encrypt(Map.get(conn.params, "password", nil))
    {username, email, id, password} = {
      Map.get(conn.params, "username", nil),
      Map.get(conn.params, "email", nil),
      Map.get(conn.params, "id", nil),
      password_hash
    }

    cond do
      is_nil(username) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "username must be present!"})

      is_nil(email) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "email must be present!"})

      is_nil(password) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "password must be present!"})

      is_nil(id) ->
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
