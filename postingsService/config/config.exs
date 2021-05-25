use Mix.Config

config :postings_management,
       db_host: "localhost",
       db_port: 27017,
       db_db: "postings",
       db_tables: [
         "postings",
         "application",
         "categories"
       ],

       api_host: "localhost",
       api_port: 3000,
       api_scheme: "http",
       app_secret_key: "secret",
       jwt_validity: 3600,
       routing_keys: %{
         # Postings, categories and applications events
         "category_added" => "jobportal.postings.category_added.events",
         "categories_find_all" => "jobportal.postings.categories_find_all.events",
       },

       event_url: "guest:guest@localhost",
         #username:passwd (here default)
       event_exchange: "logging",
       event_queue: "postings_management"