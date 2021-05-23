defmodule Api.Models.Request do
  @db_name Application.get_env(:user_management, :db_db)
  @db_table "request"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  defstruct [
    :id,
    :status,
    :company,
    :requested_by,
    :approved_by,
    :approved_on,
    :created_at,
    :updated_at,
  ]

end
