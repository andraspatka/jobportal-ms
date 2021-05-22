defmodule Api.Views.ApplicationView do
  use JSONAPI.View

  def fields, do: [:date_applied, :experience, :work_experience, :education, :user_id, :posting_id]
  def type, do: "application"
  def relationships, do: []
end


