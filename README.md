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

```bash
docker run -p 27017:27017 -d --name mongodb mongo
```

## Rabbitmq

```bash
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```
You will need to create an exchange with two bindings and a queue in order for the application to work with rabbitmq.
You may do that via the rabbitmq management UI or by simply running the following python script:
```bash
infra/createExchangeQueues.py
```
If the script gives an error, then you should verify if the USER and PASSWORD fields conform to your local rabbitmq installation.


Exchange name:
 - logging

Queue name:
 - user_management

Bindings:
 - jobportal.postings.*.events -> user_management via logging
 - jobportal.user.*.events -> user_management via logging

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
use users
db.user.insert({"created_at" : 1621715109, "email" : "admin@ntt.data.com", "firstname" : "Admin", "id" : "af711ff0-bb26-11eb-902a-708bcd51d01d", "lastname" : "Doe", "password" : "$pbkdf2-sha512$160000$5WM8kM3OFdzbe7I5G1nItQ$pnAlSCEwIz2UdfBdfWQFHf3r3biPVeiqYDZRFi1qKPz23pt2rzouAHsNTYT5NTyL7Um9URIFVBpcdUiTLECYNw", "role" : "2", "updated_at" : 1621715109 })
db.company.insert({name: "NTT Data", admin: "af711ff0-bb26-11eb-902a-708bcd51d01d"})
db.company_employee.insert({company_name: "NTT Data", user_id: "af711ff0-bb26-11eb-902a-708bcd51d01d"})

db.user.insert({"created_at" : 1621715109, "email" : "admin@msg.com", "firstname" : "Admin", "id" : "af711ff0-bb26-11eb-902a-708bcd51d01e", "lastname" : "Doe", "password" : "$pbkdf2-sha512$160000$5WM8kM3OFdzbe7I5G1nItQ$pnAlSCEwIz2UdfBdfWQFHf3r3biPVeiqYDZRFi1qKPz23pt2rzouAHsNTYT5NTyL7Um9URIFVBpcdUiTLECYNw", "role" : "2", "updated_at" : 1621715109 })
db.company.insert({name: "msg", admin: "af711ff0-bb26-11eb-902a-708bcd51d01e"})
db.company_employee.insert({company_name: "msg", user_id: "af711ff0-bb26-11eb-902a-708bcd51d01e"})

use postings
db.category.insert({"created_at" : 1621715109, "uuid" : "b4e96d9c-c121-11eb-8529-0242ac130003", "name" : "IT", "updated_at" : 1621715109 })
db.category.insert({"created_at" : 1621715109, "uuid" : "b4e96d9c-c121-11eb-8529-0242ac130004", "name" : "HR", "updated_at" : 1621715109 })
```

# Flow

- register as employee
- log in as employee
- send request to become employer
- log in as admin
- query requests
- approve with admin: 8d41b900-bd9a-11eb-8ef8-708bcd51d01d

# Skaffold

requirements:
- skaffold
- helm
- kubernetes cluster
- docker-desktop

```bash
# Deploy rabbitmq and mongodb. Mongodb has an initDbScript which inserts some test data (two companies and two users)
skaffold run -m infra

# Run script for setting up rabbitmq (create exchange, queue, bindings)
infra/createExchangeQueues.py

skaffold run -m user-management

skaffold run -m events-management

```

# Azure

```bash
az login
az aks get-credentials --resource-group jobportal --name jobportal
cd userManagementService
az acr build --image user-management-service:v1 --registry jobportal --file Dockerfile .
helm install user-management-service charts/
cd ..
skaffold run -m infra
```

# Kubectl cheat sheet

```bash
kubectl get pods
kubectl logs <pod_name>
kubectl exec -it <pod_name> -- sh
kubectl describe node
kubectl port-forward <pod_name> <host_port>:<container_port>
```