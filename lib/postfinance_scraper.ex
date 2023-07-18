defmodule PostfinanceScraper.Scraper do
  import Wallaby.Browser
  import Wallaby.Query
  @url "https://www.postfinance.ch/ap/ba/ob/html/finance/home?login"

  def scrape() do
    {:ok, session} =
      Wallaby.start_session(
        capabilities: %{
          javascriptEnabled: true,
          chromeOptions: %{
            prefs: %{
              "download.default_directory" => "/home/steven/postfinance_scraper/downloads/"
            },
            args: ["--headless"]
          }
        }
      )

    postfinance = Application.get_env(:postfinance_scraper, :postfinance) |> Map.new()

    # Visit the requested URL and fetch the page body
    visit(session, @url)
    |> fill_in(text_field("p_username"), with: postfinance.username)
    |> fill_in(text_field("p_passw"), with: postfinance.password)
    |> fill_in(text_field("p_userid"), with: postfinance.user_id)
    |> click(button("submitLogin"))
    |> assert_has(css("oklr-fido-login"))
    |> Kernel.tap(fn session ->
      File.write(
        "/home/steven/postfinance_scraper/tmp/before_logged_in.html",
        page_source(session)
      )
    end)
    |> has?(css("#widget-movements > div > fpui-widget-header-wrapper > h2"))

    transaction_url = "https://www.postfinance.ch/ap/ba/ob/html/finance/assets/movements-overview"

    session
    |> visit(transaction_url)
    |> Kernel.tap(fn session ->
      File.write(
        "/home/steven/postfinance_scraper/tmp/transactions.html",
        page_source(session)
      )
    end)
    |> assert_has(css("fpuc-movements-overview-export > button"))
    |> Kernel.tap(fn session ->
      File.write(
        "/home/steven/postfinance_scraper/tmp/transactions.html",
        page_source(session)
      )
    end)
    |> click(css("fpuc-movements-overview-export > button"))

    Process.sleep(5_000)

    # Don't forget to release resource, so you don't end up with millions of opened
    # browser windows
    :ok = Wallaby.end_session(session)
  end
end
