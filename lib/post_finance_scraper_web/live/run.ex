defmodule PostFinanceScraperWeb.Run do
  use PostFinanceScraperWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, log: [], running: false)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between">
        <.button phx-click="run" disabled={@running}>Scrape</.button>
        <.button phx-click="import_budgets" data-confirm="Are you sure about that?????" disabled={@running}>Import monthly budget transfers</.button>
      </div>
      <%= if @running do %>
        <div>Running...</div>
        <br>
        <h2>Log</h2>
      <% end %>
      <div class="flex flex-col space-y-4">
      <%= for line <- @log do %>
        <code><%= line %></code>
      <% end %>
      </div>
    </div>
    """
  end

  def handle_event("run", _params, socket) do
    self = self()

    Task.start_link(fn ->
      PostFinanceScraper.run(self)
    end)

    {:noreply, assign(socket, running: true, log: [])}
  end

  def handle_event("import_budgets", _params, socket) do
    self = self()

    Task.start_link(fn ->
      PostFinanceScraper.import_budgets(self)
    end)

    {:noreply, assign(socket, running: true, log: [])}
  end

  def handle_info({:log, log, running}, socket) do
    {:noreply, assign(socket, running: running, log: log)}
  end
end
