import Config

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
       token_verification: "http://localhost:4000/tokeninfo",
       routing_keys: %{
         # Events related to categories
         "category_added" => "jobportal.postings.category_added.events",
         "categories_find_all" => "jobportal.postings.categories_find_all.events",

         # Events related to postings
         "postings_find_all" => "jobportal.postings.postings_find_all.events",
         "postings_delete" => "jobportal.postings.postings_delete.events",
         "postings_get" => "jobportal.postings.postings_get.events",
         "postings_update" => "jobportal.postings.postings_update.events",
         "postings_save" => "jobportal.postings.postings_save.events",

         # Events related to applications
         "applications_delete" => "jobportal.postings.applications_delete.events",
         "applications_add" => "jobportal.postings.applications_add.events",
         "applications_get_for_posting" => "jobportal.postings.applications_get_for_posting.events",
         "applications_get_for_user" => "jobportal.postings.applications_get_for_user.events",
         "applications_find_all" => "jobportal.postings.applications_find_all.events"
       },

       event_url: "guest:guest@localhost",
       event_exchange: "logging",
       event_queue: "user_management"