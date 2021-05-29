import Config
# System.fetch_env!("MY_APP_SECRET_KEY")
config :user_management, :db_host, "mongodb"
config :user_management, :app_secret_key, "secret"
config :user_management, :event_url, "user:local-password@rabbitmq"
