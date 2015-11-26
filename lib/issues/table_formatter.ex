defmodule Issues.TableFormatter do
  import Enum, only: [ each: 2, map_join: 3, max: 1, map: 2 ]

  @doc """
  Takes a list of row data, where each row is a HashDict of columns,
  and list of headers to print. Prints rows data in a pretty table to STDOUT
  based on headers supplied. Width of each column is calculated in order to
  fit the biggest elemnt in a column.
  """
  def print_table_for_columns(rows, headers) do 
    data_by_columns = split_into_columns(rows, headers) 
    column_widths = widths_of(data_by_columns)
    format = format_for(column_widths)
    puts_one_line_in_columns headers, format
    IO.puts separator(column_widths)
    puts_in_columns data_by_columns, format
  end

  @doc """
  Given list of rows as HashDict of column_name: value
  and list of headers to extract, returns a list of lists,
  containing data for each column.

  ## Example
      
      iex> list = [Enum.into([{"a", 1}, {"b", 2}, {"c", 3}], HashDict.new),
      iex>         Enum.into([{"a", 4}, {"b", 5}, {"c", 6}], HashDict.new)]
      iex> Issues.TableFormatter.split_into_columns(list, ["a", "b", "c"])
      [ ["1", "4"], ["2", "5"], ["3", "6"] ]
  """
  def split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows, do: printable(row[header]) 
    end
  end

  @doc """
  Returns a string representation of parameter

  ## Example

      iex> Issues.TableFormatter.printable(123)
      "123"
      iex> Issues.TableFormatter.printable("abc")
      "abc"
  """
  def printable(str) when is_binary(str), do: str
  def printable(str), do: to_string(str)

  @doc """
  Given a list of data columns (each column is represented as lists of strings),
  returns width of each column

  ## Example

      iex> data = [ [ "cat", "wombat", "elk"], ["mongoose", "ant", "gnu"] ]
      iex> Issues.TableFormatter.widths_of(data)
      [ 6, 8 ]
  """
  def widths_of(columns) do
    for column <- columns, do: column |> map(&String.length/1) |> max
  end

  @doc """
  Return a format string that encodes known widths of columns

  ## Example
      iex> widths = [5, 6, 99]
      iex> Issues.TableFormatter.format_for(widths)
      "~-5s | ~-6s | ~-99s~n"
  """
  def format_for(column_widths) do
    map_join(column_widths, " | ", fn width -> "~-#{width}s" end) <> "~n"
  end

  @doc """
  Generate a line that separates header of the table from the body

  ## Example
      iex> widths = [5, 6, 7]
      iex> Issues.TableFormatter.separator(widths)
      "------+--------+--------"
  """
  def separator(column_widths) do
    map_join(column_widths, "-+-", fn width -> List.duplicate("-", width) end)
  end

  @doc """
  Given list of columns(represented as a list) and string that formats each row
  print data in a table
  """
  def puts_in_columns(data_by_columns, format) do 
    data_by_columns
    |> List.zip
    |> map(&Tuple.to_list/1)
    |> each(&puts_one_line_in_columns(&1, format))
  end

  def puts_one_line_in_columns(fields, format), do: :io.format(format, fields)
end
