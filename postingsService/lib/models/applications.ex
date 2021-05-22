defmodule Api.Models.Applications do
  @db_name Application.get_env(:api_test, :db_db)
  @db_table "application"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  #INFO: mongo also has an internal ID
  #ignored in this exercise
  defstruct [
    :id,
    :date_applied,
    :experience,
    :work_experience,
    :education,
    :user_id,
    :posting_id
  ]


end
