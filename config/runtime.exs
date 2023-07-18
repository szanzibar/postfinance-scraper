# config/runtime.exs
import Config
import Dotenvy

source!([".env", System.get_env()])

config :postfinance_scraper,
  postfinance: [
    username: env!("USERNAME", :string),
    password: env!("PASSWORD", :string),
    user_id: env!("USER_ID", :string)
  ],
  firefly_iii: [
    token: env!("FIREFLY_TOKEN", :string),
    url: env!("FIREFLY_URL", :string)
  ]
