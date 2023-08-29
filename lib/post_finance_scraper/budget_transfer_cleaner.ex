defmodule PostFinanceScraper.BudgetTransferCleaner do
  require Logger

  def update do
    path = "./import/budget transfers.csv"

    File.read!(path)
    |> String.trim()
    |> String.split("\r\n")
    |> update_dates
    |> Enum.join("\r\n")
    |> tap(fn contents ->
      File.write(path, contents)
    end)

    path
  end

  defp update_dates(contents) do
    today = DateTime.now!("Europe/Zurich") |> Calendar.strftime("%d-%m-%Y")

    Enum.map(contents, fn line ->
      String.replace(line, ~r/\d{2}-\d{2}-\d{4}/, today)
    end)
  end
end
