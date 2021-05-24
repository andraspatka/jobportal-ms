use Mix.Config

config :user_management,
  db_host: "localhost",
  db_port: 27017,
  db_db: "jobportal",
  db_tables: [
    "user",
    "company",
    "company_employee",
    "request"
  ],

api_host: "localhost",
api_port: 4000,
api_scheme: "http",
app_secret_key: "secret",
jwt_validity: 3600,
routing_keys: %{
  # User Events
  "user_login" => "app.login.auth-login.events",
  #"user_logout" => "api.login.auth-logout.events",
},

event_url: "user:local-password@localhost", #username:passwd (here default)
event_exchange: "my_api",
event_queue: "auth_service"
