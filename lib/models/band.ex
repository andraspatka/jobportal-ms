defmodule Api.Models.Band do
  @db_name Application.get_env(:api_test, :db_db)
  @db_table "bands"


  use Api.Models.Base
  #INFO: mongo also has an internal ID
  #ignored in this exercise
  defstruct [
    :id,
    :name,
    :year,
    :updated_at,
    :created_at
  ]
end
