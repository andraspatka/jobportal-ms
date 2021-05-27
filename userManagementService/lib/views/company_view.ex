defmodule Api.Views.CompanyView do
  use JSONAPI.View

  def fields, do: [:name]
  def type, do: "company"
  def relationships, do: []
end
