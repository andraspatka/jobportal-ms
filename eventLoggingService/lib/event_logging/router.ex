defmodule Api.Router do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )
  plug(:dispatch)

  forward("/events", to: Api.EventEndpoint)

  match _ do
    IO.puts("ERROR")
    conn
    |> send_resp(404, Poison.encode!(%{message: "Not Found"}))
  end
end
