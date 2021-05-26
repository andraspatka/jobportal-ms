defmodule Api.Helpers.EventBus do
  alias AMQP.Channel
  alias AMQP.Connection

  defmacro __using__(_opts) do
    quote do

      def start(_type, _args) do
        url = "amqp://" <> Application.get_env(:user_management, :event_url)
        exchange = Application.get_env(:user_management, :event_exchange)
        queue = Application.get_env(:user_management, :event_queue)
        {:ok, conn} = Connection.open(url)
        {:ok, chan} = Channel.open(conn)

        Agent.start_link(
          fn -> [
                  queue: queue,
                  exchange: exchange,
                  url: url,
                  chan: chan
                ]
          end,
          name: :bus_state
        )

        {:ok, self}
      end

      def start do
        start(nil, nil)
      end
    end
  end



  def publish(routing_key, payload, options \\ []) do
    state = Agent.get(:bus_state, &(&1))
    chan = Keyword.get(state, :chan)
    exchange = Keyword.get(state, :exchange)
    AMQP.Basic.publish(chan, exchange, routing_key, payload, options)
  end

end
