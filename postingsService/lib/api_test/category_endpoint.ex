defmodule Api.CategoryEndpoint do
  use Plug.Router

  alias Api.Views.CategoryView
  alias Api.Models.Category
  alias Api.Plugs.JsonTestPlug

  @api_port Application.get_env(:postings_management, :api_port)
  @api_host Application.get_env(:postings_management, :api_host)
  @api_scheme Application.get_env(:postings_management, :api_scheme)

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
    case Category.findAll(params) do
      {:ok, categories} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, categories)
      {:error, []} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, [])
    end
  end

  post "/",
       private: @skip_token_verification do

    {name} = {
      Map.get(conn.params, "name", nil)
    }

    IO.puts("New category request: #{name}")

    cond do
      is_nil(name) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Name must be present!"})

      true ->
        id = UUID.uuid1()
        case %Category{
               id: id,
               name: name,
               created_at: nil,
               updated_at: nil,
             }
             |> Category.save do
          {:ok, created_entry} ->
            conn
            |> put_status(201)
            |> assign(:jsonapi, created_entry)
          :error ->
            conn
            |> put_status(500)
            |> assign(:jsonapi, %{body: "An unexpected error happened"})
        end
    end
  end

end
