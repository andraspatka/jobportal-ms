use Mix.Config

config :api_test,
  db_host: "localhost",
  db_port: 27017,
  db_db: "postings",
  db_tables: [
    "postings",
    "application",
    "categories"
  ],

api_host: "localhost",
api_port: 3000,
api_scheme: "http",
app_secret_key: "secret",
jwt_validity: 3600

