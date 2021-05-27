defmodule Api.Views.EventView do
  use JSONAPI.View

  def fields, do: [:name, :date]
  def type, do: "event"
  def relationships, do: []
end
