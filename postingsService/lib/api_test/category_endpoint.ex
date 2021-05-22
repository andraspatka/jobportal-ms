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

    {_, categories} = Category.find(params)

    conn
    |> put_status(200)
    |> assign(:jsonapi, categories)
  end

end
