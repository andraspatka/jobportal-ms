defmodule Api.Models.Company do
  @db_name Application.get_env(:user_management, :db_db)
  @db_table "company"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  defstruct [
    :id,
    :name,
    :admin,
    :created_at,
    :updated_at
  ]

end
