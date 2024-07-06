defmodule Bot.Registry do
  require Logger

  def start_link do
    Logger.info("Starting Bot.Registry")
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def via_tuple(name) do
    {:via, Registry, {__MODULE__, name}}
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
end
