defmodule PostfinanceScraper.ExportCleaner do
  require Logger

  def clean do
    path = get_last_download()

    path
    |> File.read!()
    |> String.split("\r\n")
    |> remmove_header()
    |> remove_footer()
    |> strip_kauf_vom()
    |> fix_duplicates()
    |> Enum.join("\r\n")
    |> tap(fn contents ->
      File.write(path, contents)
    end)

    path
  end

  defp fix_duplicates(contents) do
    removed_balance =
      Enum.map(contents, fn line ->
        line |> String.split(";") |> Enum.take(5) |> Enum.join(";")
      end)

    duplicates = removed_balance -- Enum.uniq(removed_balance)

    Logger.debug("duplicates: #{inspect(duplicates)}")

    removed_duplicates = removed_balance -- duplicates

    fixed_duplicates =
      duplicates
      |> Enum.group_by(& &1)
      |> Enum.map(fn {_k, group} ->
        Enum.with_index(group)
        |> Enum.map(fn {line, index} ->
          split = line |> String.split(";")
          name = Enum.at(split, 1) |> String.replace("\"", "")

          List.replace_at(split, 1, "\"#{name} #{index}\"")
          |> Enum.join(";")
        end)
      end)
      |> List.flatten()

    removed_duplicates ++ fixed_duplicates
  end

  defp remmove_header(contents) do
    first_line = List.first(contents)

    if String.contains?(first_line, "Buchungsart") || String.contains?(first_line, "Entry type"),
      do: Enum.drop(contents, 4),
      else: contents
  end

  defp remove_footer(contents) do
    last_line = List.last(contents) |> String.trim()

    if String.contains?(last_line, "The document") ||
         String.contains?(last_line, "Der Dokumentinhalt"),
       do: Enum.drop(contents, -3),
       else: contents
  end

  defp strip_kauf_vom(contents) do
    contents
    |> Enum.map(fn line ->
      String.replace(line, ~r/Kauf\/Dienstleistung vom [\d\.]+, /, "")
    end)
  end

  def get_last_download() do
    System.cmd("ls", ["-t", "./downloads"])
    |> elem(0)
    |> String.split("\n", trim: true)
    |> List.first()
    |> then(&Path.join("./downloads", &1))
  end
end
