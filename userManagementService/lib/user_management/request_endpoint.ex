defmodule Api.RequestEndpoint do
  use Plug.Router

  alias Api.Views.RequestView
  alias Api.Models.User
  alias Api.Models.CompanyEmployee
  alias Api.Models.Company
  alias Api.Models.Request
  alias Api.Plugs.JsonTestPlug
  alias Api.Plugs.AuthPlug

  @api_port Application.get_env(:user_management, :api_port)
  @api_host Application.get_env(:user_management, :api_host)
  @api_scheme Application.get_env(:user_management, :api_scheme)

  @skip_token_verification %{jwt_skip: true}

  @status_unapproved "UNAPPROVED"
  @status_approved "APPROVED"
  @status_rejected "REJECTED"

  @role_employee 0
  @role_employer 1
  @role_admin 2

  plug :match
  plug AuthPlug
  plug :dispatch
  plug JsonTestPlug
  plug :encode_response

  defp encode_response(conn, _) do
    conn
    |>send_resp(conn.status, conn.assigns |> Map.get(:jsonapi, %{}) |> Poison.encode!)
  end

  defp get_jwt_claims(headers) do
    {:ok, service} = Api.Service.Auth.start_link

    case headers do
      ["Bearer " <> token] ->
        case Api.Service.Auth.validate_token(service, token) do
          {:ok, claims} ->
            claims
          {:error, _} ->
            :error
        end
    end

  end

  post "/", private: %{view: RequestView} do
    {:ok, claims} = get_jwt_claims(get_req_header(conn, "authorization"))
    requested_by = claims.id

    IO.puts("Requested by uuid: #{requested_by}")

    id = UUID.uuid1()
    cond do
      User.find(%{id: requested_by}) == :error ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "User: '#{requested_by}' not found!"})

      true ->
        {_, company_employee} = CompanyEmployee.find(%{user_id: requested_by})
        company = company_employee.company_name
        case %Request{id: id, status: @status_unapproved, requested_by: requested_by, company: company} |> Request.save do
          {:ok, createdEntry} ->
            conn
            |> put_status(201)
            |> assign(:jsonapi, createdEntry)
          :error ->
            conn
            |> put_status(500)
            |> assign(:jsonapi, %{"error" => "An unexpected error happened"})
        end
    end
  end

  get "/", private: %{view: RequestView} do
    {:ok, claims} = get_jwt_claims(get_req_header(conn, "authorization"))
    user_id = claims.id
    {:ok, user} = User.find(%{id: user_id})
    cond do
      user.role != @role_admin ->
        conn
        |> put_status(403)
        |> assign(:jsonapi, %{"error" => "User is not an admin"})
    end
    {:ok, company_employee} = CompanyEmployee.find(%{user_id: user_id})
    company = company_employee.company_name
    {:ok, requests} = Request.find(%{company: company, status: @status_unapproved})

    conn
    |> put_status(200)
    |> assign(:jsonapi, requests)
  end
end
