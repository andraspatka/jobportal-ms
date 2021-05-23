defmodule Api.Models.CompanyEmployee do
  @db_name Application.get_env(:user_management, :db_db)
  @db_table "company_employee"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  defstruct [
    :company_name,
    :user_id,
    :created_at,
    :updated_at,
  ]

end
