import Config

config :events_management,
       db_host: "localhost",
       db_port: 27017,
       db_db: "events",
       db_tables: [
         "events",
       ],
       api_host: "localhost",
       api_port: 4343,
       api_scheme: "http",
       event_url: "guest:guest@localhost",
       event_exchange: "logging",
       event_users_queue: "user_management"