defmodule ApiTestTest do
  use ExUnit.Case
  doctest ApiTest

  test "greets the world" do
    assert ApiTest.hello() == :world
  end
end
