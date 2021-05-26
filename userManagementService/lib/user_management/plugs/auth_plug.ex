defmodule Api.Plugs.AuthPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    cond do
      conn.private |> Map.get(:jwt_skip, false) ->
        conn
      true ->
        {:ok, service} = Api.Service.Auth.start_link
        headers = get_req_header(conn, "authorization")

        #token = headers |> List.first |> String.split(" ") |> List.last

        case headers do
          ["Bearer " <> token] ->
            case Api.Service.Auth.validate_token(service, token) do
              {:ok, _} ->
                conn
              {:error, _} ->
                conn
                |> send_resp(401, "Unauthorized")
                |> halt
            end
          _ ->
            conn
            |> send_resp(401, "Unauthorized")
            |> halt
        end
    end
  end

end
