defmodule Bot.QueryHandler do
  require Logger
  use GenServer, restart: :temporary

  def start_link(_) do
    Logger.debug("Starting Bot.QueryHandler")
    GenServer.start_link(__MODULE__, :ok)
  end

  def query(pid, %{inline_query_id: inline_query_id, query: query}) do
    GenServer.cast(pid, {:query, {inline_query_id, query}})
  end

  @impl GenServer
  def init(_) do
    {:ok, :ok}
  end
  
  @impl GenServer
  def handle_cast({:query, {inline_query_id, query}}, state) do
    _ = state
    results =
      Bot.DatabaseSupervisor.route_query(query)
      |> Enum.map(fn entry ->
        %Nadia.Model.InlineQueryResult.Audio{
          id: Map.get(entry, :id),
          title: Map.get(entry, :name),
          audio_url: Map.get(entry, :data),
          type: "audio"
        }
      end)

    Nadia.answer_inline_query(inline_query_id, results)
    {:noreply, :ok}
  end
end
