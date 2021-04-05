use Mix.Config

config :api_test,
  db_host: "localhost",
  db_port: 27017,
  db_db: "jobportal",
  db_tables: [
    "user"
  ],

api_host: "localhost",
api_port: 4000,
api_scheme: "http"
