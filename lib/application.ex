defmodule PostfinanceScraper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: PostfinanceScraper.Worker.start_link(arg)
      # {PostfinanceScraper.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PostfinanceScraper.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def run() do
    PostfinanceScraper.Scraper.scrape()

    PostfinanceScraper.ExportCleaner.clean()
    |> PostfinanceScraper.FireflyImporter.import()
  end
end
