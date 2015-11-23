defmodule CliTest do
  use ExUnit.Case
  doctest Issues.CLI

  import Issues.CLI, only: [parse_args: 1,
                            convert_to_list_of_hashdicts: 1,
                            sort_ascending: 1]
  
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

  test "ascending search works correctly" do
    result = sort_ascending(create_fake_dated_list(["b", "a", "c"]))
    issues = for issue <- result, do: issue["created_at"]
    assert issues == ~w{a b c}
  end

  defp create_fake_dated_list(list) do
    for elem <- list do
      [{"created_at", elem}, {"some_data", "test"}]
    end
    |> convert_to_list_of_hashdicts
  end
end


