defmodule Api.ApplicationEndpoint do
  use Plug.Router

  alias Api.Views.ApplicationView
  alias Api.Models.Applications
  alias Api.Plugs.JsonTestPlug

  @api_port Application.get_env(:postings_management, :api_port)
  @api_host Application.get_env(:postings_management, :api_host)
  @api_scheme Application.get_env(:postings_management, :api_scheme)

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

  delete "/:id" do
    case Applications.delete(id) do
      {:ok, application} ->

        conn
        |> put_status(200)
        |> assign(:jsonapi, %{body: "Application was successfully deleted."})

      :error ->
        conn
        |> put_status(404)
        |> assign(:jsonapi, %{body: "Application with the given id was not found."})
    end
  end

  post "/",
       private: @skip_token_verification,
       private: %{
         view: ApplicationView
       } do
    IO.puts("Adding a new application.")

    {applicationDate, numberYearsExperience, workingExperience, education, applicantId, postingId} = {
      Map.get(conn.params, "applicationDate", nil),
      Map.get(conn.params, "numberYearsExperience", nil),
      Map.get(conn.params, "workingExperience", nil),
      Map.get(conn.params, "education", nil),
      Map.get(conn.params, "applicantId", nil),
      Map.get(conn.params, "postingId", nil)
    }

    IO.puts(
      "New application request: #{applicationDate}, #{numberYearsExperience}, #{workingExperience}, #{education},  #{
        applicantId
      }, #{postingId}"
    )

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

            conn
            |> put_status(201)
            |> assign(:jsonapi, created_entry)
          :error ->
            conn
            |> put_status(500)
            |> assign(:jsonapi, %{body: "An unexpected error happened."})
        end
    end
  end

  get "/posting/:id",
      private: %{
        view: ApplicationView
      }  do
    IO.puts(id)
    case Applications.findAll(%{posting_id: id}) do
      {:ok, applications} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, applications)
      {:error, []} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, [])
    end


  end

  get "/user/:id",
      private: %{
        view: ApplicationView
      }  do
    case Applications.findAll(%{user_id: id}) do
      {:ok, applications} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, applications)
      {:error, []} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, [])
    end
  end

  get "/",
      private: %{
        view: ApplicationView
      }  do
    params = Map.get(conn.params, "filter", %{})
    case Applications.findAll(params) do
      {:ok, applications} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, applications)
      {:error, []} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, [])
    end
  end

end