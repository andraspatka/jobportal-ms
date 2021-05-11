# JobPortal Monorepo

## Architecture

![Architecture](docs/architecture.png)

Components:
- JobPortalUI: Angular web application, user interface
- JobPortalService: An aggregator microservice. Handles the communication with all other microservices. 
Its goal is to hide the complexity of the microservice architecture from the UI
- UserManagementService: Handles User registration, sign in, approvals.
- PostingsService: Handles operations relating to Postings (CRUD, apply).
- EventLoggingService: Gets events from UserMangementService and PostingsService via a RabbitMQ Queue.
Saves the Events to a MongoDB Database. 
- StatisticsService: Can query each type of Event. Handles business logic for aggregating the events and extracting
statistics from them.

UserManagementService and PostingService uses the same Database, but they use different schemas.

## Elixir

### Installation

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

### Running the project

Compile deps: mix do deps.get, deps.compile, compile
Run project: mix run --no-halt


## MongoDB

```
docker run -p 27017:27017 -d --name mongodb mongo
```

# Curls

```bash
curl -v -X POST localhost:4000/users/login?username="user"&email="email"&password="password"&id=2

curl -X POST -H "Content-Type: application/json" -d '{"email":"email@gmail.com", "password":"password"}' localhost:4000/users/login

curl -X POST -H "Content-Type: application/json" -d '{"email":"email@gmail.com", "password":"password", "id":"1", "username":"user"}' localhost:4000/users/register

curl -X GET -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImVtYWlsQGdtYWlsLmNvbSIsImV4cCI6MTYyMDY4NDgzOCwiaWF0IjoxNjIwNjgxMjM4LCJhdWQiOiJKb2tlbiIsImV4cCI6MTYyMDY4ODQzOCwiaWF0IjoxNjIwNjgxMjM4LCJpc3MiOiJKb2tlbiIsImp0aSI6IjJwdXQxdnZoZG5yNDE4bmM4czAwMDBmMSIsIm5iZiI6MTYyMDY4MTIzOH0.Pu49NXsselRnUQaCeHOgHnaFi1G7p28n2DwacTgvEuM' localhost:4000/users
```