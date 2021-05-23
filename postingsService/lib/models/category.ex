defmodule Api.Models.Category do
  @db_name Application.get_env(:api_test, :db_db)
  @db_table "categories"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  defstruct [
    :id,
    :name,
    :created_at,
    :updated_at
  ]

end
