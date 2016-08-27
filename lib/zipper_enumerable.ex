defimpl Enumerable, for: Zipper do
  @doc """
  Returns the count of the items in the zipper, including the cursor position.

  ## Examples

      iex> Enum.count(%Zipper{left: [2, 1], right: [4], cursor: 3})
      4
  """
  def count(z = %Zipper{}), do: {:ok, Zipper.count(z)}


  @doc """
  Checks if the value is a member of the Zipper, including the cursor position.

  ## Examples

      iex> Enum.member?(%Zipper{left: [1, 3, 5], right: [2, 1]}, 5)
      true

      iex> Enum.member?(Zipper.empty, "potato")
      false
  """
  def member?(%Zipper{left: [], right: [], cursor: nil}, _), do: {:ok, false}

  def member?(z = %Zipper{}, value) do
    {:ok, z.cursor == value || Enum.member?(z.right, value) || Enum.member?(z.left, value)}
  end


  @doc """
  Reduce the Zipper starting at the cursor and reducing right. Does not move
  the cursor position. Use `Zipper.cursor_start/1` if you want to start from
  the beginning.

  ## Examples

      iex> z = %Zipper{left: [2, 1], right: [4, 5], cursor: 3}
      iex> Enumerable.reduce(z, {:cont, 0}, fn(z, acc) ->
      ...>   {:cont, z.cursor + acc}
      ...>end)
      15
  """
  def reduce(%Zipper{cursor: nil, right: []}, {:cont, acc}, _fun) do
    {:done, acc}
  end

  def reduce(z = %Zipper{}, {state, acc}, fun) do
    case state do
      :cont -> reduce(Zipper.right(z), fun.(z, acc), fun)
      :halt -> {:halted, acc}
      :suspend -> {:suspended, acc, &reduce(z, &1, fun)}
    end
  end
end
