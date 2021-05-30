defmodule Api.ApplicationEndpoint do
  use Plug.Router

  alias Api.Views.ApplicationView
  alias Api.Models.Applications
  alias Api.Models.JwtToken
  alias Api.Plugs.JsonTestPlug
  alias Api.Service.Publisher

  @api_port Application.get_env(:postings_management, :api_port)
  @api_host Application.get_env(:postings_management, :api_host)
  @api_scheme Application.get_env(:postings_management, :api_scheme)
  @routing_keys Application.get_env(:postings_management, :routing_keys)
  @token_verification Application.get_env(:postings_management, :token_verification)

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

  delete "/:id" do
    headers = get_req_header(conn, "authorization")
    header = [{"Content-type", "application/json"}]
    case headers do
      ["Bearer " <> token] ->
        body = Poison.encode!(%JwtToken{jwt: token})
        case HTTPoison.post(@token_verification, body, header) do
          {_, response} ->
            cond do
              response.status_code == 200 ->
                case Applications.delete(id) do
                  {:ok, application} ->
                    Publisher.publish(
                      @routing_keys
                      |> Map.get("applications_delete"),
                      %{
                        :type => "APPLICATION_DELETED",
                        :details => "Application with the id #{application.id} was deleted."
                      }
                    )
                    conn
                    |> put_status(200)
                    |> assign(:jsonapi, %{body: "Application was successfully deleted."})

                  :error ->
                    conn
                    |> put_status(404)
                    |> assign(:jsonapi, %{body: "Application with the given id was not found."})
                end
              response.status_code == 400 -> conn
                                             |> put_status(400)
                                             |> assign(
                                                  :jsonapi,
                                                  %{body: "Token is invalid!"}
                                                )
            end
        end
    end
  end

  post "/",
       private: %{
         view: ApplicationView
       } do
    headers = get_req_header(conn, "authorization")
    header = [{"Content-type", "application/json"}]
    case headers do
      ["Bearer " <> token] ->
        body = Poison.encode!(%JwtToken{jwt: token})
        case HTTPoison.post(@token_verification, body, header) do
          {_, response} ->
            cond do
              response.status_code == 200 ->
                {applicationDate, numberYearsExperience, workingExperience, education, applicantId, postingId} = {
                  Map.get(conn.params, "applicationDate", nil),
                  Map.get(conn.params, "numberYearsExperience", nil),
                  Map.get(conn.params, "workingExperience", nil),
                  Map.get(conn.params, "education", nil),
                  Map.get(conn.params, "applicantId", nil),
                  Map.get(conn.params, "postingId", nil)
                }
                cond do
                  is_nil(numberYearsExperience) ->
                    conn
                    |> put_status(400)
                    |> assign(:jsonapi, %{error: "Number of years of experience must be present!"})

                  is_nil(workingExperience) ->
                    conn
                    |> put_status(400)
                    |> assign(:jsonapi, %{error: "Working experience must be present!"})

                  is_nil(education) ->
                    conn
                    |> put_status(400)
                    |> assign(:jsonapi, %{error: "Education must be present!"})

                  is_nil(applicationDate) ->
                    conn
                    |> put_status(400)
                    |> assign(:jsonapi, %{error: "Application date must be present!"})

                  is_nil(applicantId) ->
                    conn
                    |> put_status(400)
                    |> assign(:jsonapi, %{error: "User Id must be present!"})

                  is_nil(postingId) ->
                    conn
                    |> put_status(400)
                    |> assign(:jsonapi, %{error: "Posting id must be present!"})

                  true ->
                    id = UUID.uuid1()
                    case %Applications{
                           id: id,
                           date_applied: applicationDate,
                           experience: numberYearsExperience,
                           work_experience: workingExperience,
                           education: education,
                           user_id: applicantId,
                           posting_id: postingId,
                           created_at: nil,
                           updated_at: nil
                         }
                         |> Applications.save do
                      {:ok, created_entry} ->
                        Publisher.publish(
                          @routing_keys
                          |> Map.get("applications_add"),
                          %{
                            :type => "APPLICATION_ADDED",
                            :details => "A new application with the id #{created_entry.id} was added."
                          }
                        )
                        conn
                        |> put_status(201)
                        |> assign(:jsonapi, created_entry)
                      :error ->
                        conn
                        |> put_status(500)
                        |> assign(:jsonapi, %{body: "An unexpected error happened."})
                    end
                end
              response.status_code == 400 -> conn
                                             |> put_status(400)
                                             |> assign(
                                                  :jsonapi,
                                                  %{body: "Token is invalid!"}
                                                )
            end
        end
    end
  end

  get "/posting/:id",
      private: %{
        view: ApplicationView
      }  do
    headers = get_req_header(conn, "authorization")
    header = [{"Content-type", "application/json"}]
    case headers do
      ["Bearer " <> token] ->
        body = Poison.encode!(%JwtToken{jwt: token})
        case HTTPoison.post(@token_verification, body, header) do
          {_, response} ->
            cond do
              response.status_code == 200 ->
                case Applications.findAll(%{posting_id: id}) do
                  {:ok, applications} ->
                    Publisher.publish(
                      @routing_keys
                      |> Map.get("applications_get_for_posting"),
                      %{
                        :type => "APPLICATIONS_OF_POSTING",
                        :details => "All the applications of the posting with the id #{id} were requested."
                      }
                    )
                    conn
                    |> put_status(200)
                    |> assign(:jsonapi, applications)
                  {:error, []} ->
                    conn
                    |> put_status(200)
                    |> assign(:jsonapi, [])
                end
              response.status_code == 400 -> conn
                                             |> put_status(400)
                                             |> assign(
                                                  :jsonapi,
                                                  %{body: "Token is invalid!"}
                                                )
            end
        end
    end
  end

  get "/user/:id",
      private: %{
        view: ApplicationView
      }  do
    headers = get_req_header(conn, "authorization")
    header = [{"Content-type", "application/json"}]
    case headers do
      ["Bearer " <> token] ->
        body = Poison.encode!(%JwtToken{jwt: token})
        case HTTPoison.post(@token_verification, body, header) do
          {_, response} ->
            cond do
              response.status_code == 200 ->
                case Applications.findAll(%{user_id: id}) do
                  {:ok, applications} ->
                    Publisher.publish(
                      @routing_keys
                      |> Map.get("applications_get_for_user"),
                      %{
                        :type => "APPLICATIONS_OF_USER",
                        :details => "All the applications of the user with the id #{id} were requested."
                      }
                    )
                    conn
                    |> put_status(200)
                    |> assign(:jsonapi, applications)
                  {:error, []} ->
                    conn
                    |> put_status(200)
                    |> assign(:jsonapi, [])
                end
              response.status_code == 400 -> conn
                                             |> put_status(400)
                                             |> assign(
                                                  :jsonapi,
                                                  %{body: "Token is invalid!"}
                                                )
            end
        end
    end
  end

  get "/",
      private: %{
        view: ApplicationView
      }  do
    headers = get_req_header(conn, "authorization")
    header = [{"Content-type", "application/json"}]
    case headers do
      ["Bearer " <> token] ->
        body = Poison.encode!(%JwtToken{jwt: token})
        case HTTPoison.post(@token_verification, body, header) do
          {_, response} ->
            cond do
              response.status_code == 200 ->
                params = Map.get(conn.params, "filter", %{})
                case Applications.findAll(params) do
                  {:ok, applications} ->
                    Publisher.publish(
                      @routing_keys
                      |> Map.get("applications_find_all"),
                      %{
                        :type => "APPLICATIONS_FIND_ALL",
                        :details => "All the applications of the JobPortal were requested."
                      }
                    )
                    conn
                    |> put_status(200)
                    |> assign(:jsonapi, applications)
                  {:error, []} ->
                    conn
                    |> put_status(200)
                    |> assign(:jsonapi, [])
                end
              response.status_code == 400 -> conn
                                             |> put_status(400)
                                             |> assign(
                                                  :jsonapi,
                                                  %{body: "Token is invalid!"}
                                                )
            end
        end
    end
  end
end