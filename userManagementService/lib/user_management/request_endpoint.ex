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

  @roles Application.get_env(:user_management, :roles)

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
    claims = get_jwt_claims(get_req_header(conn, "authorization"))
    requested_by = claims.uuid
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
    claims = get_jwt_claims(get_req_header(conn, "authorization"))
    user_id = claims.uuid
    {role, _} = Integer.parse(claims.role)
    cond do
      role !== @roles.admin ->
        conn
        |> put_status(403)
        |> assign(:jsonapi, %{"error" => "User is not an admin!"})
      true ->
        {:ok, company_employee} = CompanyEmployee.find(%{user_id: user_id})
        company = company_employee.company_name
        {_, requests} = Request.find_all(%{company: company, status: @status_unapproved})
        conn
        |> put_status(200)
        |> assign(:jsonapi, requests)
    end
  end

  patch "/", private: %{view: RequestView} do
    {requestee_id, status} = {
      Map.get(conn.params, "id", nil),
      Map.get(conn.params, "status", nil),
    }
    claims = get_jwt_claims(get_req_header(conn, "authorization"))
    {role, _} = Integer.parse(claims.role)
    cond do
      role !== @roles.admin ->
        conn
        |> put_status(403)
        |> assign(:jsonapi, %{"error" => "User is not an admin!"})
      User.find(%{id: requestee_id}) === :error ->
        conn
        |> put_status(404)
        |> assign(:jsonapi, %{"error" => "User with id: #{requestee_id} not found!"})
      status !== @status_approved and status !== @status_rejected ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "Status not found! Status should be: #{@status_approved} or #{@status_rejected}"})
      true ->
        {:ok, company_employee} = CompanyEmployee.find(%{user_id: requestee_id})
        requestee_company = company_employee.company_name
        {:ok, admin_company_employee} = CompanyEmployee.find(%{user_id: claims.uuid})
        admin_company = admin_company_employee.company_name
        IO.puts("requestee: #{requestee_company} admin: #{admin_company} #{admin_company === requestee_company}")
        if admin_company !== requestee_company do
          conn
          |> put_status(400)
          |> assign(:jsonapi, %{"error" => "Incorrect admin! Not admin of company: #{requestee_company}"})
        else
          case Request.find(%{company: requestee_company, status: @status_unapproved, requested_by: requestee_id}) do
            {:ok, request} ->
              Request.delete(request.id)
              case %Request{
                    id: request.id,
                    approved_by: claims.uuid,
                    approved_on: Timex.to_unix(Timex.now),
                    company: request.company,
                    created_at: request.created_at,
                    requested_by: request.requested_by,
                    status: status
                   } |> Request.save do
                {:ok, updated_entity} ->
                  if status === @status_approved do
                    {:ok, employee} = User.find(%{id: requestee_id})
                    User.delete(employee.id)
                    %User{id: employee.id,
                      email: employee.email,
                      password: employee.password,
                      firstname: employee.firstname,
                      lastname: employee.lastname,
                      role: @roles.employer,
                      created_at: employee.created_at} |> User.save
                  end
                  conn
                  |> put_status(200)
                  |> assign(:jsonapi, updated_entity)
                :error ->
                  conn
                  |> put_status(500)
                  |> assign(:jsonapi, %{"error" => "Request could not be updated!"})
              end
            :error ->
              conn
              |> put_status(404)
              |> assign(:jsonapi, %{"error" => "No unapproved request for user with id #{requestee_id}"})
          end
        end
    end
  end
end
