defmodule PostFinanceScraper.Scraper do
  import Wallaby.Browser
  import Wallaby.Query
  @url "https://www.postfinance.ch/ap/ba/ob/html/finance/home?login"

  def scrape(caller, user \\ :steven) do
    root_dir = File.cwd!()

    {:ok, session} =
      Wallaby.start_session(
        capabilities: %{
          javascriptEnabled: true,
          chromeOptions: %{
            prefs: %{
              "download.default_directory" => "#{root_dir}/downloads/"
            },
            args: ["--headless", "--no-sandbox", "--disable-dev-shm-usage"]
          }
        }
      )

    post_finance =
      Application.get_env(:post_finance_scraper, :post_finance)[user]

    send(caller, {:log, ["Scraping...", "Please approve PostFinance login request"], true})

    # Visit the requested URL and fetch the page body
    visit(session, @url)
    |> fill_in(text_field("p_username"), with: post_finance.username)
    |> fill_in(text_field("p_passw"), with: post_finance.password)
    |> fill_in(text_field("p_userid"), with: post_finance.user_id)
    |> click(button("submitLogin"))
    |> assert_has(css("oklr-fido-login"))
    |> Kernel.tap(fn session ->
      File.write(
        "#{root_dir}/tmp/before_logged_in.html",
        page_source(session)
      )
    end)
    |> has?(css("#widget-movements > div > fpui-widget-header-wrapper > h2"))

    send(
      caller,
      {:log, ["Scraping...", "Logged in successfully. Starting to download transactions..."],
       true}
    )

    transaction_url = "https://www.postfinance.ch/ap/ba/ob/html/finance/assets/movements-overview"

    session
    |> visit(transaction_url)
    |> Kernel.tap(fn session ->
      File.write(
        "#{root_dir}/tmp/transactions.html",
        page_source(session)
      )
    end)
    |> assert_has(css("fpuc-movements-overview-export > button"))
    |> Kernel.tap(fn session ->
      File.write(
        "#{root_dir}/tmp/transactions.html",
        page_source(session)
      )
    end)
    |> click(css("fpuc-movements-overview-export > button"))

    send(
      caller,
      {:log, ["Scraping...", "Waiting 5 seconds for download to finish..."], true}
    )

    Process.sleep(5_000)

    # Don't forget to release resource, so you don't end up with millions of opened
    # browser windows
    :ok = Wallaby.end_session(session)
  end
end
