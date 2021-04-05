defmodule Api.Views.BandView do
  use JSONAPI.View

  def fields, do: [:name, :year, :created_at, :updated_at]
  def type, do: "band"
  def relationships, do: []
end
