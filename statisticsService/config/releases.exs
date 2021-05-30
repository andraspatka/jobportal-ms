import Config

config :statistics_management, :api_port, 4000
config :statistics_management, :event_management_service_url, System.fetch_env!("EVENT_MANAGEMENT_SERVICE_URL")
