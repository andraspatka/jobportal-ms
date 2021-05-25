defmodule Api.Views.RequestView do
  use JSONAPI.View

  def fields, do: [:status, :requested_by, :company, :id, :created_at]
  def type, do: "request"
  def relationships, do: []
end
