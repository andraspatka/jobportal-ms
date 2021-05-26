defmodule Api.Views.UserView do
  use JSONAPI.View

  def fields, do: [:email, :firstname, :lastname, :role, :id]
  def type, do: "user"
  def relationships, do: []
end
