defmodule Api.PostingEndpoint do
  use Plug.Router

  alias Api.Views.PostingView
  alias Api.Models.Posting
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

  get "/",
      private: %{
        view: PostingView
      }  do
    params = Map.get(conn.params, "filter", %{})

    case Posting.findAll(params) do
      {:ok, postings} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, postings)
      {:error, []} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, [])
    end
  end

  delete "/:id" do
    case Posting.delete(id) do
      {:ok, posting} ->
        conn
        |> put_status(200)
        |> assign(:jsonapi, %{body: "Posting was successfully deleted."})

      :error ->
        conn
        |> put_status(404)
        |> assign(:jsonapi, %{body: "Posting with the given id was not found."})
    end
  end

  get "/:id",
      private: %{
        view: PostingView
      }  do
    case Posting.get(id) do
      {:ok, posting} ->

        conn
        |> put_status(200)
        |> assign(:jsonapi, posting)

      :error ->
        conn
        |> put_status(404)
        |> assign(:jsonapi, %{body: "Posting with the given id was not found."})
    end
  end

  patch "/",
        private: @skip_token_verification,
        private: %{
          view: PostingView
        }  do
    IO.puts("Editing a post.")

    {id, deadline, name, description, requirements} = {
      Map.get(conn.params, "id", nil),
      Map.get(conn.params, "deadline", nil),
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "description", nil),
      Map.get(conn.params, "requirements", nil)
    }

    IO.puts("Editing posting: #{id}, #{deadline}, #{name}, #{description}, #{requirements}")

    cond do
      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Posting ID must be present!"})
      true ->
        case Posting.find(%{id: id}) do
          {:ok, posting} ->
            Posting.delete(id)
            case %Posting{
                   id: posting.id,
                   posted_by: posting.posted_by,
                   created_at: posting.created_at,
                   deadline: deadline,
                   number_of_views: posting.number_of_views,
                   name: name,
                   description: description,
                   category_id: posting.category_id,
                   requirements: requirements,
                   updated_at: nil
                 }
                 |> Posting.save do
              {:ok, updated_entity} ->
                conn
                |> put_status(201)
                |> assign(:jsonapi, updated_entity)
              :error ->
                conn
                |> put_status(500)
                |> assign(:jsonapi, %{body: "Posting could not be updated."})
            end
          :error ->
            conn
            |> put_status(404)
            |> assign(:jsonapi, %{body: "Posting with the given Id was not found."})
        end
    end
  end

  post "/",
       private: @skip_token_verification,
       private: %{
         view: PostingView
       } do
    IO.puts("Adding a new posting...")

    {postedById, postedAt, deadline, numberOfViews, name, description, categoryId, requirements} = {
      Map.get(conn.params, "postedById", nil),
      Map.get(conn.params, "postedAt", nil),
      Map.get(conn.params, "deadline", nil),
      Map.get(conn.params, "numberOfViews", nil),
      Map.get(conn.params, "name", nil),
      Map.get(conn.params, "description", nil),
      Map.get(conn.params, "categoryId", nil),
      Map.get(conn.params, "requirements", nil),
    }

    IO.puts(
      "New posting request: #{postedById}, #{postedAt}, #{deadline}, #{numberOfViews}, #{
        name
      }, #{description}, #{categoryId},  #{requirements}"
    )

    cond do
      is_nil(postedById) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Employer Id must be present!"})

      is_nil(postedAt) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Posting date must be present!"})

      is_nil(deadline) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Deadline must be present!"})

      is_nil(numberOfViews) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Number of views must be present!"})

      is_nil(name) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Name must be present!"})

      is_nil(description) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Description must be present!"})

      is_nil(categoryId) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Category id must be present!"})

      is_nil(requirements) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{error: "Requirements must be present!"})

      true ->
        id = UUID.uuid1()
        case %Posting{
               id: id,
               posted_by: postedById,
               created_at: postedAt,
               deadline: deadline,
               number_of_views: numberOfViews,
               name: name,
               description: description,
               category_id: categoryId,
               requirements: requirements,
               updated_at: nil
             }
             |> Posting.save do
          {:ok, created_entity} ->
            conn
            |> put_status(201)
            |> assign(:jsonapi, created_entity)
          :error ->
            conn
            |> put_status(500)
            |> assign(:jsonapi, %{body: "An unexpected error happened."})
        end
    end
  end
end