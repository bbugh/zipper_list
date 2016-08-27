defimpl Enumerable, for: ZipperList do
  @doc """
  Returns the count of the items in the zipper, including the cursor position.

  ## Examples

      iex> Enum.count(%ZipperList{left: [2, 1], right: [4], cursor: 3})
      4
  """
  def count(z = %ZipperList{}), do: {:ok, ZipperList.count(z)}


  @doc """
  Checks if the value is a member of the ZipperList, including the cursor position.

  ## Examples

      iex> Enum.member?(%ZipperList{left: [1, 3, 5], cursor: 8, right: [2, 1]}, 5)
      true

      iex> Enum.member?(ZipperList.empty, "potato")
      false
  """
  def member?(%ZipperList{left: [], right: [], cursor: nil}, _), do: {:ok, false}

  def member?(z = %ZipperList{}, value) do
    {:ok, z.cursor == value || Enum.member?(z.right, value) || Enum.member?(z.left, value)}
  end


  @doc """
  Reduce the ZipperList starting at the cursor and reducing right. Does not move
  the cursor position. Use `ZipperList.cursor_start/1` if you want to start from
  the beginning.

  ## Examples

      iex> z = %ZipperList{left: [2, 1], cursor: 3, right: [4, 5]}
      iex> Enumerable.reduce(z, {:cont, 0}, fn(z, acc) ->
      ...>   {:cont, z.cursor + acc}
      ...>end)
      {:done, 12}
  """
  def reduce(%ZipperList{cursor: nil, right: []}, {:cont, acc}, _fun) do
    {:done, acc}
  end

  def reduce(z = %ZipperList{}, {state, acc}, fun) do
    case state do
      :cont -> reduce(ZipperList.right(z), fun.(z, acc), fun)
      :halt -> {:halted, acc}
      :suspend -> {:suspended, acc, &reduce(z, &1, fun)}
    end
  end
end
