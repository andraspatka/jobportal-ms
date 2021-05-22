defmodule UserManagementTest do
  use ExUnit.Case
  doctest UserManagement

  test "greets the world" do
    assert UserManagement.hello() == :world
  end
end
