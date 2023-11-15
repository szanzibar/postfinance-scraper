defmodule PostFinanceScraperWeb.Run do
  use PostFinanceScraperWeb, :live_view

  def mount(_parameters, _session, socket) do
    socket = assign(socket, log: [], running: false)
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      case params["user"] do
        user when user in ~w(steven kathrin) -> assign(socket, user: user)
        _ -> assign(socket, user: "steven")
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
    <div class="flex justify-between">
    <h1 class="text-3xl"><%= String.capitalize(@user) %></h1>
      <.button phx-click="switch_user" disabled={@running}>Switch user</.button>
      </div>
    <hr class="my-5" />
      <div class="flex justify-between">
        <.button phx-click="run" disabled={@running}>Scrape</.button>
        <.button phx-click="import_budgets" data-confirm="Are you sure about that?????" disabled={@running}>Import monthly budget transfers</.button>
      </div>
      <%= if @running do %>
        <div>Running... Please leave this page open</div>
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

  def handle_event("switch_user", _params, socket) do
    user = socket.assigns.user

    new_user =
      case user do
        "steven" -> "kathrin"
        "kathrin" -> "steven"
        _ -> "steven"
      end

    socket = assign(socket, user: new_user)

    {:noreply, push_patch(socket, to: "/?user=#{new_user}", replace: true)}
  end

  def handle_event("run", _params, socket) do
    user = String.to_existing_atom(socket.assigns.user)
    self = self()

    Task.start_link(fn ->
      PostFinanceScraper.run(self, user)
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
