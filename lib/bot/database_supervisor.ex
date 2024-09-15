defmodule Bot.DatabaseSupervisor do
  require Logger
  @pool_size 3

  def start_link() do
    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def route_query(query) do
    Bot.Database.exec_query(choose_worker(query), query)
  end

  def worker_spec(worker_id) do
    default_worker_spec = {Bot.Database, worker_id}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def child_spec(_args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
