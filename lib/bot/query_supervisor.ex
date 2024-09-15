defmodule Bot.QuerySupervisor do
  require Logger

  def start_link() do
    Logger.info("Starting Bot.QuerySupervisor")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def start_child(query) do
    DynamicSupervisor.start_child(__MODULE__, {Bot.QueryHandler, query})
  end

  def child_spec(_args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
end
