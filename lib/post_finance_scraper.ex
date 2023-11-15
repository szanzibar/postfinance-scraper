defmodule PostFinanceScraper do
  @moduledoc """
  PostFinanceScraper keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def run(caller, user) do
    send(caller, {:log, ["Scraping..."], true})
    PostFinanceScraper.Scraper.scrape(caller, user)

    send(caller, {:log, ["Cleaning export..."], true})

    PostFinanceScraper.ExportCleaner.clean()
    |> tap(fn _ -> send(caller, {:log, ["Importing into firefly..."], true}) end)
    |> PostFinanceScraper.FireflyImporter.import()
    |> tap(fn results -> send(caller, {:log, results, false}) end)
  end

  def import_budgets(caller) do
    send(caller, {:log, ["Updating import date..."], true})
    path = PostFinanceScraper.BudgetTransferCleaner.update()

    send(caller, {:log, ["Importing into firefly..."], true})

    results =
      PostFinanceScraper.FireflyImporter.import(
        path,
        "./import/import_budget_transfers.json"
      )

    send(caller, {:log, results, false})
  end
end
