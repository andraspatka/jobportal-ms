defmodule Api.Models.User do
  @db_name Application.get_env(:user_management, :db_db)
  @db_table "user"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  #INFO: mongo also has an internal ID
  defstruct [
    :id,
    :email,
    :password,
    :firstname,
    :lastname,
    :role,
    :created_at,
    :updated_at,
  ]


end
