defmodule Issues.StringUtils do
  @moduledoc """
  Some useful utils to work with strings 
  """
  def max_length(list), do: Enum.max_by(list, &String.length/1) |> String.length()
end
