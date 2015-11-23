defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle commant line arguments parsing
  and calling other modules to produce a 
  table with last n issues of a project on github
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  Parses command line arguments

  Supported `argv` are -h, --help return usage
  Otherwise it's username project [number_of_issues]

  Return a tuple { user, project, count }, or :help if it was requested
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    case parse do
      { [help: true], _, _ } -> :help
      { _, [user, project, count], _ } -> { user, project, String.to_integer(count) }
      { _, [user, project], _ } -> { user, project, @default_count }
      _ -> :help
    end
  end

  @doc """
  Print help message
  """
  defp process(:help) do
    IO.puts """
    usage: issues user project [count | #{@default_count}]
    """
    System.halt(0)
  end

  @doc """
  Process data from input and return issues
  """
  defp process({ user, project, count }) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> convert_to_list_of_hashdicts
    |> sort_ascending
    |> Enum.take(count)
    |> Issues.TableFormatter.print_table_for_columns(["number", "created_at", "title"])
  end

  @doc """
  Decode JSON data recieved from Github
  """
  defp decode_response({:ok, data}), do: data

  defp decode_response({:error, data}) when is_atom(data) do
    IO.puts "Error fetching from GitHub: #{data}"
    System.halt(2)
  end

  defp decode_response({:error, data}) do
    {_, message} = List.keyfind(data, "message", 0)
    IO.puts "Error fetching from GitHub: #{message}"
    System.halt(2)
  end

  @doc """
  Convert data from Github to convinient list of HashDicts
  """
  def convert_to_list_of_hashdicts(list) do
    list
    |> Enum.map(&Enum.into(&1, HashDict.new))
  end

  @doc """
  Sort data recieved from GitHub in ascending order
  """
  def sort_ascending(list) do
    list 
    |> Enum.sort fn e1, e2 -> e1["created_at"] <= e2["created_at"] end
  end
end
