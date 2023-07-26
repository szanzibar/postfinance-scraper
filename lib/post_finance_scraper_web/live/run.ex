defmodule PostFinanceScraperWeb.Run do
  use PostFinanceScraperWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, log: "", running: false)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.button phx-click="run" class="mb-4">Scrape</.button>
      <%= if @running do %>
        <div>Running...</div>
      <% end %>
      <div><%= @log %></div>
    </div>
    """
  end

  def handle_event("run", _params, socket) do
    self = self()

    Task.start_link(fn ->
      results = PostFinanceScraper.run()
      send(self, {:run_finished, results})
    end)

    {:noreply, assign(socket, running: true, log: "Please approve PostFinance login request")}
  end

  def handle_info({:run_finished, results}, socket) do
    {:noreply, assign(socket, running: false, log: results)}
  end
end
