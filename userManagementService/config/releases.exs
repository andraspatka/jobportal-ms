import Config

config :user_management, :db_host, System.fetch_env!("MONGODB_HOST")
config :user_management, :app_secret_key, System.fetch_env!("APP_SECRET_KEY")
config :user_management, :event_url, "#{System.fetch_env!("RABBITMQ_USER")}:#{System.fetch_env!("RABBITMQ_PASSWORD")}@#{System.fetch_env!("RABBITMQ_HOST")}"
