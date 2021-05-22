use Mix.Config

config :user_management,
  db_host: "localhost",
  db_port: 27017,
  db_db: "jobportal",
  db_tables: [
    "user"
  ],

api_host: "localhost",
api_port: 4000,
api_scheme: "http",
app_secret_key: "secret",
jwt_validity: 3600

