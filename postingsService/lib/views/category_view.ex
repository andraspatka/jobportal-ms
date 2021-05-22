defmodule Api.Views.CategoryView do
  use JSONAPI.View

  def fields, do: [:name]
  def type, do: "category"
  def relationships, do: []
end
