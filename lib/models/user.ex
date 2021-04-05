defmodule Api.Models.User do
  @db_name Application.get_env(:api_test, :db_db)
  @db_table "user"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  #INFO: mongo also has an internal ID
  #ignored in this exercise
  defstruct [
    :id,
    :username,
    :email,
    :password,
    :created_at,
    :updated_at,
  ]


end
