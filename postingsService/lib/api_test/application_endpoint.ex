defmodule Api.ApplicationEndpoint do
  use Plug.Router

  alias Api.Views.ApplicationView
  alias Api.Models.Applications
  alias Api.Plugs.JsonTestPlug

  @api_port Application.get_env(:api_test, :api_port)
  @api_host Application.get_env(:api_test, :api_host)
  @api_scheme Application.get_env(:api_test, :api_scheme)

  @skip_token_verification %{jwt_skip: true}

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

  delete "/:id",
         private: %{
           view: ApplicationView
         }  do
    {parsedId, ""} = Integer.parse(id)

    case Applications.delete(parsedId) do
      {:ok, application} ->

        conn
        |> put_status(200)
        |> assign(:jsonapi, application)

      :error ->
        conn
        |> put_status(404)
        |> assign(:jsonapi, %{"error" => "'application' not found"})
    end
  end

  # TODO: application ID
  post "/",
       private: @skip_token_verification,
       private: %{
         view: ApplicationView
       } do
    IO.puts("Adding a new application...")

    {id, numberYearsExperience, workingExperience, education, applicationDate, applicantId, postingId} = {
      Map.get(conn.params, "id", nil),
      Map.get(conn.params, "numberYearsExperience", nil),
      Map.get(conn.params, "workingExperience", nil),
      Map.get(conn.params, "education", nil),
      Map.get(conn.params, "applicationDate", nil),
      Map.get(conn.params, "applicantId", nil),
      Map.get(conn.params, "postingId", nil)
    }

    IO.puts(
      "New application request: #{id}, #{numberYearsExperience}, #{workingExperience}, #{education}, #{applicationDate}, #{
        applicantId
      }, #{postingId}"
    )

    cond do
      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Id must be present!"})

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
        case %Applications{
               id: id,
               date_applied: applicationDate,
               experience: numberYearsExperience,
               work_experience: workingExperience,
               education: education,
               user_id: applicantId,
               posting_id: postingId
             }
             |> Applications.save do
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

  get "/posting/:id",
      private: %{
        view: ApplicationView
      }  do
    {postingId, ""} = Integer.parse(id)

    {_, applications} = Applications.find(%{posting_id: postingId})

    conn
    |> put_status(200)
    |> assign(:jsonapi, applications)
  end

  get "/user/:id",
      private: %{
        view: ApplicationView
      }  do
    {userId, ""} = Integer.parse(id)

    {_, applications} = Applications.find(%{user_id: userId})

    conn
    |> put_status(200)
    |> assign(:jsonapi, applications)
  end

end