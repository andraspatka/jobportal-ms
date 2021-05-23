defmodule Api.Models.Applications do
  @db_name Application.get_env(:postings_management, :db_db)
  @db_table "application"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  defstruct [
    :id,
    :date_applied,
    :experience,
    :work_experience,
    :education,
    :user_id,
    :posting_id,
    :created_at,
    :updated_at
  ]


end
