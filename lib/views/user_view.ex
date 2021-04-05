defmodule Api.Views.UserView do
  use JSONAPI.View

  def fields, do: [:username, :email]
  def type, do: "user"
  def relationships, do: []
end
