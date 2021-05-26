defmodule Api.Models.JwtToken do
  alias Api.Helpers.MapHelper

  use Api.Models.Base
  defstruct [
    :jwt
  ]

end
