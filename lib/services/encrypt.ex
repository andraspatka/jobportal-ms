defmodule Api.Encrypt do
  @moduledoc false

  def encrypt(password) do
    Pbkdf2.hash_pwd_salt(password)
  end

  def check(password, password_hash) do
    Pbkdf2.verify_pass(password, password_hash)
  end

end
