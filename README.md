# ApiTest

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `api_test` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:api_test, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/api_test](https://hexdocs.pm/api_test).

## TODO

- Step 1. install mongo
- Step 2. create db (use bands)
- Step 3. run and test band api
- Step 4. implment User Management Api

- Api pentru User Management:
- /users/register POST
- /users/login POST => %{"message": :ok}
- /users PATCH (UPDATE username)
- User(id, username, email, password)

## Running the project

Compile deps: mix do deps.get, deps.compile, compile
Run project: mix run --no-halt

