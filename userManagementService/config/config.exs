use Mix.Config

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
         # Todo: Refactor this to use atoms as keys
         # User Events
         :user_login => "jobportal.user.login.events",
         :user_logout => "jobportal.user.logout.events",
         :user_register => "jobportal.user.register.events",
         :user_find_id => "jobportal.user.find_id.events",
         :user_find_all => "jobportal.user.find_all.events",

         # Company events
         :company_added => "jobportal.user.company_added.events",
         :companies_get_all => "jobportal.user.company_get_all.events"
       },

       roles: %{
         :employee => 0,
         :employer => 1,
         :admin => 2
       },

       event_url: "guest:guest@localhost",
       event_exchange: "logging",
       event_queue: "user_management"
