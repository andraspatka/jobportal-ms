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

## Datamodel

![Datamodel](docs/datamodel.png)

## Elixir

### Running the project

Compile deps: 

```
  mix do deps.get, deps.compile, compile
```

Run project: 
```
mix run --no-halt
```


## MongoDB

```
docker run -p 27017:27017 -d --name mongodb mongo
```

# Curls

```bash
curl -v -X POST localhost:4000/users/login?username="user"&email="email"&password="password"&id=2

curl -X POST -H "Content-Type: application/json" -d '{"email":"email@gmail.com", "password":"password"}' localhost:4000/users/login
curl -X POST -H "Content-Type: application/json" -d '{"email":"email@gmail.com", "password":"password"}' localhost:4000/users/logout

curl -X POST -H "Content-Type: application/json" -d '{"email":"email@gmail.com", "password":"password", "id":"1", "username":"user"}' localhost:4000/users/register

curl -X GET -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImVtYWlsQGdtYWlsLmNvbSIsImV4cCI6MTYyMDY4NDgzOCwiaWF0IjoxNjIwNjgxMjM4LCJhdWQiOiJKb2tlbiIsImV4cCI6MTYyMDY4ODQzOCwiaWF0IjoxNjIwNjgxMjM4LCJpc3MiOiJKb2tlbiIsImp0aSI6IjJwdXQxdnZoZG5yNDE4bmM4czAwMDBmMSIsIm5iZiI6MTYyMDY4MTIzOH0.Pu49NXsselRnUQaCeHOgHnaFi1G7p28n2DwacTgvEuM' localhost:4000/users
```

# Some test data

```bash
db.user.insert({"company" : "NTT Data", "created_at" : 1621715109, "email" : "joe@ntt.data.com", "first_name" : "John", "id" : "af711ff0-bb26-11eb-902a-708bcd51d01d", "last_name" : "Doe", "password" : "$pbkdf2-sha512$160000$5WM8kM3OFdzbe7I5G1nItQ$pnAlSCEwIz2UdfBdfWQFHf3r3biPVeiqYDZRFi1qKPz23pt2rzouAHsNTYT5NTyL7Um9URIFVBpcdUiTLECYNw", "role" : "1", "updated_at" : 1621715109 })
db.company.insert({name: "NTT Data", admin: "af711ff0-bb26-11eb-902a-708bcd51d01d"})
```