defmodule Zipper do
  @moduledoc """
  A Haskell-inspired Zipper list implementation.

  A Zipper allows for rapid left and right traversal on a list in constant time.
  Useful for cases where a simple enumeration won't work. If you have to use
  [`Enum.at/2`](http://elixir-lang.org/docs/stable/elixir/Enum.html#at/3)
  repeatedly, consider using `Zipper` instead.

  ## Usage

  The value at the current position is stored in `%Zipper{cursor}`, and the
  items to the left and write are in `%Zipper{left}` and `%Zipper{right}` like:

      iex> zip = %Zipper{left: [3, 2, 1], cursor: 4, right: [5, 6]}
      iex> zip |> Zipper.right
      %Zipper{left: [4, 3, 2, 1], cursor: 5, right: [6]}
      iex> zip |> Zipper.left |> Zipper.left
      %Zipper{left: [1], cursor: 2, right: [3, 4, 5, 6]}

  ## Using with Enum

  `Zipper` implements `Enumerable`, so all `Enum` methods will work with Zipper.
  However, **all functions start enumerating at the cursor position**. If you
  need to enumerate the whole zipper, use `Zipper.cursor_start/1` to reset it.

      iex> zip = Zipper.from_lists([1, 2, 3], [4, 5, 6])
      iex> Enum.map(zip, fn(z) -> z.cursor * 3 end)
      [12, 15, 18]

      iex> zip = Zipper.from_lists([1, 2, 3], [4, 5, 6])
      iex> Enum.map(Zipper.cursor_start(zip), fn(z) -> z.cursor * 3 end)
      [3, 6, 9, 12, 15, 18]

  ## Accessing data in the zipper

  If you choose to directly access `%Zipper{left}` keep in mind that it is
  stored in reverse:

      iex> Zipper.from_lists([1, 2, 3], [4, 5, 6])
      %Zipper{left: [3, 2, 1], cursor: 4, right: [5, 6]}

      iex> Zipper.to_list(%Zipper{left: [3, 2, 1], cursor: 4, right: [5, 6]})
      [1, 2, 3, 4, 5, 6]

  ## Reference

  See the Wikipidia article "[Zipper data
  structure](https://en.wikipedia.org/wiki/Zipper_\(data_structure\))" for more
  (mathematically complicated) information.
  """
  @type t :: %Zipper{left: list, cursor: any, right: list}
  defstruct left: [], cursor: nil, right: []


  @doc """
  Returns an empty Zipper with the cursor position at the front.

  ## Examples

      iex> Zipper.empty
      %Zipper{left: [], cursor: nil, right: []}
  """
  @spec empty :: Zipper.t
  def empty, do: %Zipper{}


  @doc """
  Returns a new Zipper with the cursor from `Zipper.right`'s first element.

  ## Examples

      iex> Zipper.from_lists([1, 2, 3], [4, 5])
      %Zipper{left: [3, 2, 1], cursor: 4, right: [5]}
  """
  @spec from_lists(list, list) :: Zipper.t
  def from_lists(left, [c | right]) do
    %Zipper{left: Enum.reverse(left), cursor: c, right: right}
  end


  @doc """
  Returns a zipper containing the elements of `xs`, with the cursor at the first
  element.

  ## Examples

      iex> Zipper.from_list([1, 2, 3])
      %Zipper{left: [], cursor: 1, right: [2, 3]}
  """
  @spec from_list(list) :: Zipper.t
  def from_list([c | xs]), do: %Zipper{right: xs, cursor: c}


  @doc """
  Returns a zipper containing the elements of `xs`, focused just off the right
  end of the list.

  ## Examples

      iex> zip = Zipper.from_list_end([1, 2, 3])
      %Zipper{left: [3, 2, 1], cursor: nil, right: []}
      iex> Zipper.end? zip
      true
  """
  @spec from_list_end(list) :: Zipper.t
  def from_list_end(xs), do: %Zipper{left: Enum.reverse(xs)}


  @doc """
  Returns a list from the zipper.

  ## Examples

      iex> Zipper.to_list(%Zipper{left: [3,2,1], cursor: 4, right: [5,6]})
      [1, 2, 3, 4, 5, 6]
  """
  @spec to_list(Zipper.t) :: list
  def to_list(z = %Zipper{}) do
    Enum.reverse(z.left) ++ [z.cursor | z.right]
  end


  @doc """
  Returns `true` if the zipper is at the start.

  ## Examples

      iex> Zipper.beginning?(%Zipper{left: [], cursor: 0, right: [1, 2, 3]})
      true

      iex> Zipper.beginning?(%Zipper{left: [2, 1], cursor: 3, right: [4]})
      false
  """
  @spec beginning?(Zipper.t) :: boolean
  def beginning?(%Zipper{left: []}), do: true
  def beginning?(%Zipper{}), do: false


  @doc """
  Returns `true` if the zipper is at the end.

  ## Examples

      iex> Zipper.end?(%Zipper{left: [3, 2, 1], cursor: nil, right: []})
      true

      iex> Zipper.end?(%Zipper{left: [2, 1], cursor: 3, right: [4]})
      false
  """
  @spec end?(Zipper.t) :: boolean
  def end?(%Zipper{cursor: nil, right: []}), do: true
  def end?(%Zipper{}), do: false


  @doc """
  Returns `true` if the zipper is empty.

  ## Examples

      iex> Zipper.empty?(Zipper.empty)
      true

      iex> Zipper.empty?(%Zipper{left: [3, 2, 1], cursor: 4})
      false
  """
  @spec empty?(Zipper.t) :: boolean
  def empty?(%Zipper{left: [], cursor: nil, right: []}), do: true
  def empty?(%Zipper{}), do: false


  @doc """
  Returns the zipper with the cursor set to the start. O(1)

  ## Examples

      iex> Zipper.cursor_start(%Zipper{left: [2, 1], cursor: 3, right: [4]})
      %Zipper{left: [], cursor: 1, right: [2, 3, 4]}
  """
  @spec cursor_start(Zipper.t) :: Zipper.t
  def cursor_start(z = %Zipper{left: [], right: []}), do: z
  def cursor_start(z = %Zipper{}) do
    [cursor | right] = Enum.reverse(z.left) ++ [z.cursor | z.right]
    %Zipper{cursor: cursor, right: right}
  end


  @doc """
  Returns the zipper with the cursor set to the end. `cursor` will be nil. O(1)

  ## Examples

      iex> Zipper.cursor_end(%Zipper{left: [2, 1], cursor: 3, right: [4, 5]})
      %Zipper{left: [5, 4, 3, 2, 1], cursor: nil, right: []}
  """
  @spec cursor_end(Zipper.t) :: Zipper.t
  def cursor_end(z = %Zipper{right: []}), do: z
  def cursor_end(z = %Zipper{left: [], right: []}), do: z
  def cursor_end(z = %Zipper{}) do
    %Zipper{cursor: nil, left: Enum.reverse(z.right) ++ [z.cursor | z.left]}
   end


  @doc """
  Returns the zipper with the cursor focus shifted one element to the left, or
  `zipper` if the cursor is already at the beginning.

  Use `Zipper.begin?` to check if the zipper is at the beginning.

  ## Examples

      iex> Zipper.left(%Zipper{left: [2, 1], cursor: 3, right: [4]})
      %Zipper{left: [1], cursor: 2, right: [3, 4]}

      iex> Zipper.left(%Zipper{left: [], cursor: 1, right: [2, 3]})
      %Zipper{left: [], cursor: 1, right: [2, 3]}
  """
  @spec left(Zipper.t) :: Zipper.t
  def left(z = %Zipper{left: []}), do: z
  def left(z = %Zipper{left: [head | tail]}) do
    %Zipper{cursor: head, left: tail, right: [z.cursor | z.right]}
  end


  @doc """
  Returns the zipper with the cursor focus shifted one element to the right, or
  returns `zipper` if the cursor is past the end.

  Use `Zipper.end?` to check if the zipper is at the end.

  ## Examples

  The cursor moves out of the `right` list:

      iex> Zipper.right(%Zipper{left: [2, 1], cursor: 3, right: [4, 5]})
      %Zipper{left: [3, 2, 1], cursor: 4, right: [5]}

  If it is on the last item, `cursor` will be `nil`.

      iex> Zipper.right(%Zipper{left: [3, 2, 1], cursor: 4, right: []})
      %Zipper{left: [4, 3, 2, 1], cursor: nil, right: []}

  If the cursor is at the end, `right` returns the zipper:

      iex> Zipper.right(%Zipper{left: [4, 3, 2, 1], cursor: nil, right: []})
      %Zipper{left: [4, 3, 2, 1], cursor: nil, right: []}
  """
  @spec right(Zipper.t) :: Zipper.t
  def right(z = %Zipper{cursor: nil, right: []}), do: z
  def right(z = %Zipper{cursor: cursor, right: []}) do
    %{z | cursor: nil, left: [cursor | z.left]}
  end
  def right(z = %Zipper{right: [head | tail]}) do
    %Zipper{cursor: head, left: [z.cursor | z.left], right: tail}
  end


  @doc """
  Inserts `value` at the cursor position, pushing the current cursor and all
  values to the right.

  ## Examples

  Inserting a value replaces the cursor:

      iex> Zipper.insert(%Zipper{left: [1], cursor: 2, right: [3]}, 5)
      %Zipper{left: [1], cursor: 5, right: [2, 3]}

  On empty zippers, it inserts at the cursor position:

      iex> Zipper.insert(Zipper.empty, 5)
      %Zipper{left: [], cursor: 5, right: []}

  Any values are pushed to the right:

      iex> Zipper.insert(%Zipper{left: [], cursor: 5, right: []}, 10)
      %Zipper{left: [], cursor: 10, right: [5]}
  """
  @spec insert(Zipper.t, any) :: Zipper.t
  def insert(z = %Zipper{cursor: nil}, value), do: %{z | cursor: value}
  def insert(z = %Zipper{right: right}, value) do
    %{z | cursor: value, right: [z.cursor | right]}
  end


  @doc """
  Drops the value in the cursor and replaces it with the next value from the
  right.

  ## Examples

      iex> Zipper.delete(%Zipper{left: [3], cursor: 4, right: [5, 2]})
      %Zipper{left: [3], cursor: 5, right: [2]}

      iex> Zipper.delete(Zipper.empty)
      %Zipper{left: [], cursor: nil, right: []}

  If there is no value to the right, `cursor` will be `nil`:

      iex> Zipper.delete(%Zipper{left: [2, 5, 3], cursor: 8, right: []})
      %Zipper{left: [2, 5, 3], cursor: nil, right: []}
  """
  @spec delete(Zipper.t) :: Zipper.t
  def delete(z = %Zipper{cursor: nil}), do: z
  def delete(z = %Zipper{cursor: _c, right: []}) do
    %{z | cursor: nil}
  end
  def delete(z = %Zipper{right: [cursor | right]}) do
    %{z | cursor: cursor, right: right}
  end


  @doc """
  Pushes a value into the position before the cursor, leaving the cursor
  unchanged.

  ## Examples

      iex> Zipper.push(%Zipper{left: [1], cursor: 2, right: [3, 4]}, 5)
      %Zipper{left: [5, 1], cursor: 2, right: [3, 4]}
      iex> Zipper.push(Zipper.empty, 5)
      %Zipper{left: [5], cursor: nil, right: []}
  """
  @spec push(Zipper.t, any) :: Zipper.t
  def push(z = %Zipper{left: left}, value) do
    %{z | left: [value | left]}
  end


  @doc """
  Pops a value off of the position before the cursor. If there are no values to
  the left of the cursor, it returns `zipper`.

  ## Examples

      iex> Zipper.pop(%Zipper{left: [1], cursor: 2, right: [3, 4]})
      %Zipper{left: [], cursor: 2, right: [3, 4]}

      iex> Zipper.pop(Zipper.empty)
      %Zipper{left: [], cursor: nil, right: []}
  """
  @spec pop(Zipper.t) :: Zipper.t
  def pop(z = %Zipper{left: []}), do: z
  def pop(z = %Zipper{left: [_ | left]}) do
    %{z | left: left}
  end


  @doc """
  Replaces the zipper's cursor with the passed in `value`. If there is no
  current cursor, the value becomes the new cursor.

  ## Examples

      iex> Zipper.replace(%Zipper{left: [1], cursor: 2, right: [3, 4]}, 5)
      %Zipper{left: [1], cursor: 5, right: [3, 4]}

      iex> Zipper.replace(Zipper.empty, 5)
      %Zipper{left: [], cursor: 5, right: []}
  """
  @spec replace(Zipper.t, any) :: Zipper.t
  def replace(z = %Zipper{}, value) do
    %{z | cursor: value}
  end


  @doc """
  Returns the zipper with the elements in the reverse order. O(1).

  The cursor "position" is shifted, but the value does not change. If the cursor
  was at the start, it's now at the end, and if it was at the end, it's now at
  the start.

  ## Examples

      iex> Zipper.reverse(%Zipper{left: [2, 1], cursor: 3, right: [4]})
      %Zipper{left: [4], cursor: 3, right: [2, 1]}

      iex> Zipper.reverse(%Zipper{left: [], cursor: 1, right: [2, 3, 4]})
      %Zipper{left: [2, 3, 4], cursor: 1, right: []}
  """
  @spec reverse(Zipper.t) :: Zipper.t
  def reverse(z = %Zipper{left: left, right: right}) do
    %{z | left: right, right: left}
  end


  @doc """
  Returns the count of the number of elements in the zipper, including the
  cursor.

  ## Examples

      iex> Zipper.count(%Zipper{left: [2, 1], cursor: 3, right: [4, 5]})
      5
  """
  @spec count(Zipper.t) :: integer
  def count(%Zipper{left: [], cursor: nil, right: []}), do: 0
  def count(%Zipper{left: left, cursor: nil, right: []}), do: length(left)
  def count(%Zipper{left: left, cursor: _c, right: right}) do
    length(left) + length(right) + 1
  end
end
