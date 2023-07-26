defmodule PostFinanceScraperWeb.Run do
  use PostFinanceScraperWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, log: "")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.button phx-click="run" class="mb-4">Scrape</.button>
      <div><%= @log %></div>
    </div>
    """
  end

  def handle_event("run", _params, socket) do
    # brightness = socket.assigns.brightness + 10
    {:noreply, assign(socket, log: "clicked")}
  end
end
