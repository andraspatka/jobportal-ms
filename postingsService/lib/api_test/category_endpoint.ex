defmodule Api.CategoryEndpoint do
  use Plug.Router

  alias Api.Views.CategoryView
  alias Api.Models.Category
  alias Api.Models.JwtToken
  alias Api.Plugs.JsonTestPlug
  alias Api.Service.Publisher

  @api_port Application.get_env(:postings_management, :api_port)
  @api_host Application.get_env(:postings_management, :api_host)
  @api_scheme Application.get_env(:postings_management, :api_scheme)
  @routing_keys Application.get_env(:postings_management, :routing_keys)

  defp tokeninfo_endp() do
    Application.get_env(:postings_management, :token_verification)
  end

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
    headers = get_req_header(conn, "authorization")
    header = [{"Content-type", "application/json"}]
    case headers do
      ["Bearer " <> token] ->
        body = Poison.encode!(%JwtToken{jwt: token})
        case HTTPoison.post(tokeninfo_endp, body, header) do
          {_, response} ->
            cond do
              response.status_code == 200 ->
                params = Map.get(conn.params, "filter", %{})
                case Category.findAll(params) do
                  {:ok, categories} ->
                    Publisher.publish(
                      @routing_keys
                      |> Map.get("categories_find_all"),
                      %{
                        :type => "CATEGORIES_FIND_ALL",
                        :details => "All the existing categories in the JobPortal were requested."
                      }
                    )
                    conn
                    |> put_status(200)
                    |> assign(:jsonapi, categories)
                  {:error, []} ->
                    conn
                    |> put_status(404)
                    |> assign(:jsonapi, [])
                end
              response.status_code == 400 -> conn
                                             |> put_status(400)
                                             |> assign(
                                                  :jsonapi,
                                                  %{body: "Token is invalid!"}
                                                )
              true ->
                conn
                |> put_status(response.status_code)
                |> assign(:jsonapi, %{body: "Unexpected error: #{response.status_code}"})
            end
        end
    end
  end

  post "/" do
    headers = get_req_header(conn, "authorization")
    header = [{"Content-type", "application/json"}]
    case headers do
      ["Bearer " <> token] ->
        body = Poison.encode!(%JwtToken{jwt: token})
        case HTTPoison.post(tokeninfo_endp, body, header) do
          {_, response} ->
            cond do
              response.status_code == 200 ->
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
                        Publisher.publish(
                          @routing_keys
                          |> Map.get("category_added"),
                          %{
                            :type => "CATEGORY_ADDED",
                            :details => "A new category with the name #{created_entry.name} was added in the JobPortal."
                          }
                        )
                        conn
                        |> put_status(201)
                        |> assign(:jsonapi, created_entry)

                      :error ->
                        conn
                        |> put_status(500)
                        |> assign(:jsonapi, %{body: "An unexpected error happened"})
                    end
                end
              response.status_code == 400 -> conn
                                             |> put_status(400)
                                             |> assign(
                                                  :jsonapi,
                                                  %{body: "Token is invalid!"}
                                                )
              true ->
                conn
                |> put_status(response.status_code)
                |> assign(:jsonapi, %{body: "Unexpected error: #{response.status_code}"})
            end
        end
    end
  end
end
