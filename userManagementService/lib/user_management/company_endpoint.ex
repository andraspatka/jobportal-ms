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
    Publisher.publish(
      @routing_keys.companies_get_all,
      %{
        :type => "COMPANIES_GET",
        :details => "All companies from the JobPortal were requested."
      }
    )

    conn
    |> put_status(200)
    |> assign(:jsonapi, companies)
  end


  post "/" do
    {name, admin} = {
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "admin", nil)
    }

    IO.puts("New company request: #{name}")

    cond do
      is_nil(name) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Name must be present!"})
      is_nil(admin) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Admin id must be present!"})
      true ->
        id = UUID.uuid1()
        case %Company{
               id: id,
               name: name,
               admin: admin,
               created_at: nil,
               updated_at: nil
             }
             |> Company.save do
          {:ok, created_entry} ->
            Publisher.publish(
              @routing_keys.company_added,
              %{
                :type => "COMPANY_ADDED",
                :details => "Company with name #{created_entry.name} was added in the JobPortal."
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
  end
end
