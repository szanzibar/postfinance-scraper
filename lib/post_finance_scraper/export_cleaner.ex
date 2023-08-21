defmodule PostFinanceScraper.ExportCleaner do
  require Logger

  def clean do
    path = get_last_download()

    path
    |> File.read!()
    |> String.trim()
    |> String.split("\r\n")
    |> select_header_and_transactions()
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

  defp select_header_and_transactions(contents) do
    sections =
      Enum.chunk_while(
        contents,
        [],
        fn line, acc ->
          if line == "",
            do: {:cont, Enum.reverse(acc), []},
            else: {:cont, [line | acc]}
        end,
        fn acc ->
          {:cont, acc, []}
        end
      )

    case Enum.count(sections) do
      4 ->
        # fresh transaction export has:
        # 5 ish lines of info about csv
        # column headers
        # transaction data
        # disclaimer
        Enum.concat([Enum.at(sections, 1), [""], Enum.at(sections, 2)])

      2 ->
        # We'll assume export has already been processed and has:
        # column headers
        # transaction data
        Enum.concat([Enum.at(sections, 0), [""], Enum.at(sections, 1)])

      _ ->
        Logger.error("Unexpected number of sections: #{inspect(sections)}")
        Enum.concat(sections)
    end
  end

  defp strip_kauf_vom(contents) do
    contents
    |> Enum.map(fn line ->
      # Some transactions have a prefix that is later removed, possibly when it clears?
      # Clearing the prefix in advance prevents duplicates
      # Two examples I've seen:
      # "Kauf/Onlineshopping vom 21.07.2023, SBB Ticket Shop" shortened to "SBB Ticket Shop"
      # "Kauf/Dienstleistung vom 07.07.2023, Coop-1340 Seuzach" shortened to "Coop-1340 Seuzach"
      String.replace(line, ~r/Kauf\/\w+ vom [\d\.]+, /, "")
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
