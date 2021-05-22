defmodule Api.CategoryEndpoint do
  use Plug.Router

  alias Api.Views.CategoryView
  alias Api.Models.Category
  alias Api.Plugs.JsonTestPlug

  @api_port Application.get_env(:api_test, :api_port)
  @api_host Application.get_env(:api_test, :api_host)
  @api_scheme Application.get_env(:api_test, :api_scheme)

  @skip_token_verification %{jwt_skip: true}

  plug :match
  plug :dispatch
  plug JsonTestPlug
  plug :encode_response

  defp encode_response(conn, _) do
    conn
    |> send_resp(
         conn.status,
         conn.assigns
         |> Map.get(:jsonapi, %{})
         |> Poison.encode!
       )
  end

  get "/",
      private: %{
        view: CategoryView
      }  do
    params = Map.get(conn.params, "filter", %{})

    {_, categories} = Category.findAll(params)

    conn
    |> put_status(200)
    |> assign(:jsonapi, categories)
  end

  post "/",
       private: @skip_token_verification do

    {id, name} = {
      Map.get(conn.params, "id", nil),
      Map.get(conn.params, "name", nil)
    }

    IO.puts("New category request: #{id}, #{name}")

    cond do
      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Id must be present!"})
      is_nil(name) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Name must be present!"})

      true ->
        case %Category{
               id: id,
               name: name,
               created_at: nil,
               updated_at: nil,
             }
             |> Category.save do
          {:ok, createdEntry} ->
            conn
            |> put_status(201)
            |> assign(:jsonapi, %{body: "Category successfully added!"})
          :error ->
            conn
            |> put_status(500)
            |> assign(:jsonapi, %{body: "An unexpected error happened"})
        end
    end
  end

end
