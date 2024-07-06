defmodule Bot.Database do
  require Logger
  alias Exqlite.Sqlite3
  use GenServer

  def start_link(count) do
    GenServer.start_link(__MODULE__, :ok, name: via_tuple(count))
  end

  def exec_query(worker, query) do
    GenServer.call(via_tuple(worker), {:query, query})
  end
  
  @impl true
  def init(_) do
    Logger.info("Starting Bot.Database")
    {:ok, %{connection: nil}, {:continue, :open}}
  end

  @impl true
  def handle_continue(:open, _state) do
    {:ok, connection} = Sqlite3.open("./persist/teste.sqlite", mode: :readonly)

    map = %{connection: connection}
    {:noreply, map}
  end

  @impl true
  def handle_call({:query, query}, _, state) do
    %{connection: conn} = state
    result =
      get_data(conn, query)
      |> Enum.map(fn entry ->
        [id, name, data] = entry
        %{id: id, name: name, data: data}
      end)

    {:reply, result, state}
  end

  def get_data(conn, query) do
    sql = """
    SELECT *
    FROM MUSICS
    WHERE NAME LIKE ?1
    """

    like = "%#{query}%"
        
    {:ok, statement} = Sqlite3.prepare(conn, sql)
    :ok = Sqlite3.bind(conn, statement, [like])
    {:ok, data} = Sqlite3.fetch_all(conn, statement)

    data
  end
  
  defp via_tuple(count) do
    Bot.Registry.via_tuple({__MODULE__, count})
  end
end
