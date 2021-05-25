defmodule Api.Service.Auth do
  use GenServer
  use Timex

  @app_secret_key Application.get_env(:user_management, :app_secret_key)
  @jwt_validity Application.get_env(:user_management, :jwt_validity)
  @issuer :api

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def verify_hash(server, {password, hash}) do
    GenServer.call(server, {:verify_hash, {password, hash}})
  end

  def generate_hash(server, password) do
    GenServer.call(server, {:generate_hash, password})
  end

  def handle_call({:generate_hash, password}, _from, state) do
    {:reply, Pbkdf2.hash_pwd_salt(password), state}
  end

  def handle_call({:verify_hash, {password, hash}}, _from, state) do
    {:reply, Pbkdf2.verify_pass(password, hash), state}
  end

  def issue_token(server, user) when is_map(user) do
    GenServer.call(server, {:revoke_token, user})
    GenServer.call(server, {:issue_token, user})
  end

  def handle_call({:issue_token, claims}, _from, state) when is_map(claims) do
    signer = Joken.Signer.create("HS256", :base64.encode(@app_secret_key))

    {:ok, jwt, _} = claims |> Map.merge(%{
      iat: Timex.to_unix(Timex.now),
      exp: Timex.to_unix(Timex.shift(Timex.now, seconds: @jwt_validity))
    })
    |> Api.Token.generate_and_sign(signer)

    :ets.insert(:users, {claims.email, jwt})

    {:reply, jwt, state}
  end

  def revoke_token(server, user) when is_map(user) do
    GenServer.call(server, {:revoke_token, user})
  end

  def handle_call({:revoke_token, claims}, _from, state) when is_map(claims) do
    x = case :ets.lookup(:users, claims.email) do
      [{_, _}] ->
        :ets.delete(:users, claims.email)
        :ok
      _ -> :error
    end

    {:reply, x, state}
  end

  def validate_token(server, token) do
    GenServer.call(server, {:validate_token, token})
  end

  def handle_call({:validate_token, token}, _from, state) when is_binary(token) do
    signer = Joken.Signer.create("HS256", :base64.encode(@app_secret_key))

    result = Api.Token.verify_and_validate(token, signer)

    case result do
      {:ok, claims} ->
        tClaims = Api.Helpers.MapHelper.string_keys_to_atoms(claims)
        case :ets.lookup(:users, tClaims.email) do
          [{_, _}] ->
            {:reply, {:ok, tClaims}, state}
          _ -> {:reply, {:error, "Token invalid."}, state}
        end
      {:error, _} ->
        {:reply, {:error, "Token signature invalid."}, state}
    end
  end

end
