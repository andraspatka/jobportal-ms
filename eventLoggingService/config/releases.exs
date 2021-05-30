import Config

config :events_management, :api_port, 4000
config :events_management, :db_host, System.fetch_env!("MONGODB_HOST")
config :events_management, :event_url, "#{System.fetch_env!("RABBITMQ_USER")}:#{System.fetch_env!("RABBITMQ_PASSWORD")}@#{System.fetch_env!("RABBITMQ_HOST")}"
config :events_management, :token_verification, "#{System.fetch_env!("USER_MANAGEMENT_SERVICE_URL")}/tokeninfo"