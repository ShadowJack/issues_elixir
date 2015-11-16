defmodule CliTest do
  use ExUnit.Case
  doctest Issues.CLI

  import Issues.CLI, only: [parse_args: 1]
  
  test ":help is returned when calling with key -h or --help" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "three values are returned if three given" do
    assert parse_args(["user", "project", "100"]) == { "user", "project", 100 }
  end

  test "default count is set when not provided in key" do
    assert parse_args(["user", "project"]) == { "user", "project", 4 }
  end

end


