import Mix.Config

config :user_management,
       db_host: "localhost",
       db_port: 27017,
       db_db: "users",
       db_tables: [
         "user",
         "company",
         "company_employee",
         "request"
       ],
       api_host: "localhost",
       api_port: 4000,
       api_scheme: "http",
       app_secret_key: "secret",
       jwt_validity: 3600,
       routing_keys: %{
         # User Events
         :user_login => "jobportal.user.login.events",
         :user_logout => "jobportal.user.logout.events",
         :user_register => "jobportal.user.register.events",
         :companies_get_all => "jobportal.user.get_companies.events"
       },
       roles: %{
         :employee => 0,
         :employer => 1,
         :admin => 2
       },
       event_url: "user:local-password@localhost",
       event_exchange: "logging",
       event_queue: "user_management"
