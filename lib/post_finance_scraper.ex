defmodule PostFinanceScraper do
  @moduledoc """
  PostFinanceScraper keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def run(caller) do
    send(caller, {:log, ["Scraping...", "Please approve PostFinance login request"], true})
    PostFinanceScraper.Scraper.scrape()

    send(caller, {:log, ["Cleaning export..."], true})

    PostFinanceScraper.ExportCleaner.clean()
    |> tap(fn _ -> send(caller, {:log, ["Importing into firefly..."], true}) end)
    |> PostFinanceScraper.FireflyImporter.import()
    |> tap(fn results -> send(caller, {:log, results, false}) end)
  end
end
