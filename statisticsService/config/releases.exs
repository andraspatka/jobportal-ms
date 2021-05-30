import Config

config :statistics_management, :db_host, System.fetch_env!("MONGODB_HOST")
