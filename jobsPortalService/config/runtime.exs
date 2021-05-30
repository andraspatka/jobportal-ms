import Config

config :portal_management, :api_port, 4000
config :portal_management, :user_management_service_url, System.get_env("USER_MANAGEMENT_SERVICE_URL", "http://localhost:4000")
config :portal_management, :posting_management_service_url, System.get_env("POSTING_MANAGEMENT_SERVICE_URL", "http://localhost:3000")
config :portal_management, :statistics_service_url, System.get_env("STATISTICS_SERVICE_URL", "http://localhost:9000")
config :portal_management, :origin, ["http://localhost:4200", System.get_env("CORS", "http://localhost:4200")]