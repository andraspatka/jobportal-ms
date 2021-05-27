defmodule Api.Models.Event do
  @db_name Application.get_env(:events_management, :db_db)
  @db_table "events"

  alias Api.Helpers.MapHelper

  use Api.Models.Base
  defstruct [
    :id,
    :name,
    :date,
    :updated_at
  ]

end
