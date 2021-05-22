defmodule Router do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/auth", to: Endpoints.AuthEndpoint)
  forward("/posting", to: Endpoints.PostingEndpoint)
  match _ do
    conn
    |> send_resp(404, Poison.encode!(%{message: "Not Found"}))
  end
end