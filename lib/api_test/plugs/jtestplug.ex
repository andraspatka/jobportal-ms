defmodule Api.Plugs.JsonTestPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    case conn.private |> Map.get(:view, nil) do
      nil ->
        conn
      view->
        resp = conn.assigns |> Map.get(:jsonapi, %{})

        cond do
          #ist_list(resp) && conn.status == 200 ->
          #implement pagination
          conn.status in [200, 201] ->
            resp = JSONAPI.Serializer.serialize(view, resp, conn)

            conn
            |> put_status(conn.status)
            |> assign(:jsonapi, resp)

          true ->
            conn
        end

    end
  end
end
