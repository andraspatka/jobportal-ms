defmodule Api.Views.EventView do
  use JSONAPI.View

  def fields, do: [:type, :details, :created_at]
  def type, do: "event"
  def relationships, do: []
end
