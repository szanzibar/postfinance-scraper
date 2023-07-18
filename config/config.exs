import Config

Application.put_env(:wallaby, :max_wait_time, 60_000)

config :wallaby,
  chromedriver: [
    path: "./chromedriver"
  ],
  hackney_options: [timeout: 15_000]
