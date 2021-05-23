defmodule Api.Models.Posting do
  @db_name Application.get_env(:postings_management, :db_db)
  @db_table "postings"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  defstruct [
    :id,
    :posted_by,
    :created_at,
    :deadline,
    :number_of_views,
    :name,
    :description,
    :category_id,
    :requirements,
    :updated_at
  ]


end
