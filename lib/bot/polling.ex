defmodule Bot.Polling do
  require Logger
  use GenServer

  def start_link(_) do
    Logger.info("Starting Bot.Polling")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    get_updates()
    {:ok, 0, 5000}
  end
  
  def get_updates do
    GenServer.cast(__MODULE__, :update)
  end

  def handle_cast(:update, state) do
    {:ok, data} = Nadia.get_updates offset: state, timeout: 10
    offset = process_update({state, data |> List.last})
    {:noreply, offset, 250}
  end

  def process_update({offset, data}) when data == nil do
    offset
  end

  def process_update({offset, data}) when data.inline_query != nil do
    _ = offset
    %{
      update_id: offset,
      inline_query:
        %{
          id: inline_query_id,
          from: %{id: user_id},
          query: query
        }
    } = data
    {:ok, pid} = Bot.QuerySupervisor.start_child(query)
    Bot.QueryHandler.query(pid, %{inline_query_id: inline_query_id, from: user_id, query: query})
    offset + 1
  end

  def process_update({offset, data}) when data.chosen_inline_result != nil do
  offset + 1
  end
                                         
  def handle_info(:timeout, state) do
    get_updates()
    {:noreply, state}
  end
  
end
