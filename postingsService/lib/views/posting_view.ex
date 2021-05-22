defmodule Api.Views.PostingView do
  use JSONAPI.View

  def fields,
      do: [:id, :posted_by, :posted_at, :deadline, :number_of_views, :name, :description, :category_id, :requirements]
  def type, do: "posting"
  def relationships, do: []
end