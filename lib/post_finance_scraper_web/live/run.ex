defmodule PostFinanceScraperWeb.Run do
  use PostFinanceScraperWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, log: [], running: false)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.button phx-click="run" class="mb-4" disabled={@running}>Scrape</.button>
      <%= if @running do %>
        <div>Running...</div>
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

    {:noreply, assign(socket, running: true, log: ["Please approve PostFinance login request"])}
  end

  def handle_info({:log, log, running}, socket) do
    {:noreply, assign(socket, running: running, log: log)}
  end
end
