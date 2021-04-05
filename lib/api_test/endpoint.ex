defmodule Api.Endpoint do
  use Plug.Router


  alias Api.Views.BandView
  alias Api.Models.Band
  alias Api.Plugs.JsonTestPlug

  @api_port Application.get_env(:api_test, :api_port)
  @api_host Application.get_env(:api_test, :api_host)
  @api_scheme Application.get_env(:api_test, :api_scheme)

  plug :match
  plug :dispatch
  plug JsonTestPlug
  plug :encode_response


  defp encode_response(conn, _) do
    conn
    |>send_resp(conn.status, conn.assigns |> Map.get(:jsonapi, %{}) |> Poison.encode!)
  end

  get "/", private: %{view: BandView}  do
    params = Map.get(conn.params, "filter", %{})

    {_, bands} =  Band.find(params)

    conn
    |> put_status(200)
    |> assign(:jsonapi, bands)
  end

  get "/:id", private: %{view: BandView}  do
    {parsedId, ""} = Integer.parse(id)

    case Band.get(parsedId) do
      {:ok, band} ->
        #without the test plug just call the serializer manually
        #(plug :encode_response must be in this care removed)
        #resp = JSONAPI.Serializer.serialize(BandView, band, conn)
        # conn
        #|> put_resp_content_type("application/json")
        #|> send_resp(200, Poison.encode!(resp))

        conn
        |> put_status(200)
        |> assign(:jsonapi, band)

      :error ->
        conn
        |> put_status(404)
        |> assign(:jsonapi, %{"error" => "'band' not found"})
    end
  end

  delete "/:id" do
    {parsedId, ""} = Integer.parse(id)

    case Band.delete(parsedId) do
      :error ->
         conn
         |> put_status(404)
         |> assign(:jsonapi, %{"error" => "'band' not found"})
      :ok ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, %{message: "#{id} was deleted"})
    end

  end

  patch "/:id", private: %{view: BandView} do
    #not tested
    {parsedId, ""} = Integer.parse(id)

    {name, year} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "year", nil)
    }

    Band.delete(parsedId)

    case %Band{name: name, year: year, id: parsedId} |> Band.save do
      {:ok, createdEntry} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, createdEntry)
      :error ->
        conn
         |> put_status(500)
         |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
    end
  end

  post "/", private: %{view: BandView} do
    {name, year, id} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "year", nil),
      Map.get(conn.params, "id", nil)
    }

    cond do
      is_nil(name) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "name must be present!"})

      is_nil(year) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "year must be present!"})

      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "id must be present!"})

      true ->
      case %Band{name: name, year: year, id: id} |> Band.save do
        {:ok, createdEntry} ->
          uri = "#{@api_scheme}://#{@api_host}:#{@api_port}#{conn.request_path}/"
          #not optimal

          conn
          |> put_resp_header("location", "#{uri}#{id}")
          |> put_status(201)
          |> assign(:jsonapi, createdEntry)
        :error ->
          conn
           |> put_status(500)
           |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
      end
    end
  end
end
