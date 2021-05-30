import Config

config :portal_management, :api_port, 4000
config :portal_management, :user_management_service_url, System.fetch_env!("USER_MANAGEMENT_SERVICE_URL")
config :portal_management, :posting_management_service_url, System.fetch_env!("POSTING_MANAGEMENT_SERVICE_URL")
config :portal_management, :statistics_service_url, System.fetch_env!("STATISTICS_SERVICE_URL")
config :portal_management, :origin, ["http://localhost:4200", System.System.fetch_env!("CORS")]