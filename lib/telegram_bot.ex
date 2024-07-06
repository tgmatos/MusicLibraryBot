defmodule TelegramBot do
  require Logger
  use Application

  def start(_, _) do
    Logger.info("Starting application")
    children = [
      Bot.Registry,
      Bot.Polling,
      Bot.QuerySupervisor,
      Bot.DatabaseSupervisor
    ]
    opts = [strategy: :one_for_one]

    Logger.info("Bot name: #{Application.get_env(:telegram_bot, :name)}")
    config = Application.get_env(:nadia, :token)
    Logger.info(config)
    
    Supervisor.start_link(children, opts)
  end
end
