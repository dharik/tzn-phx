defmodule Tzn.SlackNotifier do
  require Logger

  def send_to_coding(message) do
    if Mix.env() in [:dev, :test] do
      Logger.info("Message to slack: " <> message)
    else
      HTTPoison.post(
        "https://hooks.slack.com/services/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",
        Jason.encode!(%{
          text: message
        })
      )
    end
  end
end
