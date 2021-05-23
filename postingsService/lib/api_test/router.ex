defmodule Api.Router do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )
  plug(:dispatch)

  forward("/applications", to: Api.ApplicationEndpoint)
  forward("/categories", to: Api.CategoryEndpoint)
  forward("/postings", to: Api.PostingEndpoint)

  match _ do
    conn
    |> send_resp(404, Poison.encode!(%{message: "Not Found"}))
  end
end
