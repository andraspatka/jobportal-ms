import Config

#import_config "#{Mix.env()}.exs"

config :portal_management,
    api_host: "localhost",
    api_port: 8000,
    api_scheme: "http",
    # endpoint_url: %{
    #     :login => "http://localhost:4000/users/login/",
    #     :register => "http://localhost:4000/users/register/",
    #     :companies => "http://localhost:4000/companies/",
    #     :applications => "http://localhost:3000/applications/",
    #     :categories => "http://localhost:3000/categories/",
    #     :posting => "http://localhost:3000/postings/",
    #     :request => "http://localhost:4000/requests"
    # }
    origin: "http://localhost:4200",
    login: "http://localhost:4000/users/login/",
    register: "http://localhost:4000/users/register/",
    companies: ["http://localhost:4000/companies/"],
    applications: "http://localhost:3000/applications/",
    categories: "http://localhost:3000/categories/",
    posting: "http://localhost:3000/postings/",
    request: "http://localhost:4000/requests"