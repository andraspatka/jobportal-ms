defmodule Api.Service.Consumer do
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


  def consume(queue) do
    Api.Helpers.EventBus.consume(queue)
  end
end
