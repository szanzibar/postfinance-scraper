defmodule PostFinanceScraper.FireflyImporter do
  require Logger

  def import(csv_path) do
    firefly = Application.get_env(:post_finance_scraper, :firefly_iii) |> Map.new()

    headers = [Authorization: "Bearer #{firefly.token}", Accept: "application/json"]

    body =
      {:multipart,
       [
         {:file, csv_path, {"form-data", [name: "importable", filename: Path.basename(csv_path)]},
          []},
         {:file, "./import/import.json", {"form-data", [name: "json", filename: "import.json"]},
          []}
       ]}

    HTTPoison.post(firefly.url, body, headers, timeout: 60_000, recv_timeout: 60_000)
    |> parse_response
  end

  defp parse_response({:ok, response}) do
    response.body
    |> String.split("\n", trim: true)
    |> Enum.reject(&String.contains?(&1, "Duplicate of transaction"))
    |> Enum.join("\n")
    |> tap(&Logger.info(&1))
  end

  defp parse_response({:error, error}) do
    inspect(error)
  end
end
