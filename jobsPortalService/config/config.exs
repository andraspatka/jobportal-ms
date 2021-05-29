import Config

config :portal_management,
    api_host: "localhost",
    api_port: 8000,
    api_scheme: "http",
    user_management_service_url: "http://localhost:4000",
    posting_management_service_url: "http://localhost:3000",
    statistics_service_url: "http://localhost:9000",
    endpoint_url: %{
        :user_login => "/users/login",
        :user_register => "/users/register",
        :user_companies => "/companies",
        :user_request => "/requests",
        :posting_applications => "/applications",
        :posting_categories => "/categories",
        :posting_posting => "/postings",
        :statistics => "/statistics",
    },
    origin: ["http://localhost:4200"]