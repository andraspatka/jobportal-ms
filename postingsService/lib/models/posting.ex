defmodule Api.Models.Posting do
  @db_name Application.get_env(:api_test, :db_db)
  @db_table "postings"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  #INFO: mongo also has an internal ID
  #ignored in this exercise
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
