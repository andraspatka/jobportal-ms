defmodule Api.JwtValidation do
  use Plug.Router

  alias Api.Plugs.JsonTestPlug

  @api_port Application.get_env(:user_management, :api_port)
  @api_host Application.get_env(:user_management, :api_host)
  @api_scheme Application.get_env(:user_management, :api_scheme)

  plug :match
  plug :dispatch
  plug JsonTestPlug
  plug :encode_response

  defp encode_response(conn, _) do
    conn
    |>send_resp(conn.status, conn.assigns |> Map.get(:jsonapi, %{}) |> Poison.encode!)
  end

  post "/" do
    {jwt} = {
      Map.get(conn.params, "jwt", nil),
    }
    IO.puts("JWT validation tokeninfo endpoint called...")
    {:ok, service} = Api.Service.Auth.start_link
    case Api.Service.Auth.validate_token(service, jwt) do
      {:ok, _} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, %{message: "Valid token!"})
      {:error, _} ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{message: "Invalid token!"})
    end
  end

end
