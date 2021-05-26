defmodule Api.Service.Publisher do
  use Api.Helpers.EventBus
  use Timex

  require Poison

  def start_link(_), do: start

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end


  def publish(routing_key, payload, options \\ []) do
    Api.Helpers.EventBus.publish(
      routing_key,
      Poison.encode!(payload),
      options ++ [
        app_id: "auth_service",
        content_type: "application/json",
        persistent: true
      ]
    )
  end
end
