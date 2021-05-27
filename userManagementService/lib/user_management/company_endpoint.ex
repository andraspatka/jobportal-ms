defmodule Api.CompanyEndpoint do
  use Plug.Router

  alias Api.Models.Company
  alias Api.Views.CompanyView
  alias Api.Plugs.JsonTestPlug
  alias Api.Service.Publisher

  @api_port Application.get_env(:user_management, :api_port)
  @api_host Application.get_env(:user_management, :api_host)
  @api_scheme Application.get_env(:user_management, :api_scheme)

  @routing_keys Application.get_env(:user_management, :routing_keys)

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
        view: CompanyView
      }  do
    {_, companies} = Company.find_all(%{})
    IO.inspect(companies)

    conn
    |> put_status(200)
    |> assign(:jsonapi, companies)
  end
end
