defmodule EventLoggingTest do
  use ExUnit.Case
  doctest EventLogging

  test "greets the world" do
    assert EventLogging.hello() == :world
  end
end
