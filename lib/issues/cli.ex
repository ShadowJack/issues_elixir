defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle commant line arguments parsing
  and calling other modules to produce a 
  table with last n issues of a project on github
  """

  def run(argv) do
    argv
    |> parse_args()
    |> process()
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

  def process(:help) do
    IO.puts """
    usage: issues user project [count | #{@default_count}]
    """
    System.halt(0)
  end

  def process({ user, project, count }) do
    Issues.GithubIssues.fetch(user, project)
  end
end
