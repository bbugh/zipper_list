defmodule ZipperList do
  @moduledoc """
  A Haskell-inspired zipper list implementation.

  A `ZipperList` allows for rapid left and right traversal on a list in constant
  time. Useful for cases where a simple enumeration won't work. If you have to
  use [`Enum.at/2`](http://elixir-lang.org/docs/stable/elixir/Enum.html#at/3)
  repeatedly, consider using `ZipperList` instead.

  ## Usage

  The value at the current position is stored in `%ZipperList{cursor}`, and the
  items to the left and write are in `%ZipperList{left}` and
  `%ZipperList{right}` like:

      iex> zip = %ZipperList{left: [3, 2, 1], cursor: 4, right: [5, 6]}
      iex> zip |> ZipperList.right
      %ZipperList{left: [4, 3, 2, 1], cursor: 5, right: [6]}
      iex> zip |> ZipperList.left |> ZipperList.left
      %ZipperList{left: [1], cursor: 2, right: [3, 4, 5, 6]}

  ## Using with Enum

  `ZipperList` implements the `Enumerable` protocol, so all `Enum` methods will
  work with `ZipperList`. However, **all functions start enumerating at the
  cursor position**. If you need to enumerate the whole zipper, use
  `ZipperList.cursor_start/1` to reset it.

      iex> zip = ZipperList.from_lists([1, 2, 3], [4, 5, 6])
      iex> Enum.map(zip, fn(z) -> z.cursor * 3 end)
      [12, 15, 18]

      iex> zip = ZipperList.from_lists([1, 2, 3], [4, 5, 6])
      iex> Enum.map(ZipperList.cursor_start(zip), fn(z) -> z.cursor * 3 end)
      [3, 6, 9, 12, 15, 18]

  ## Accessing data in the zipper

  If you choose to directly access `%ZipperList{left}` keep in mind that it is
  stored in reverse:

      iex> ZipperList.from_lists([1, 2, 3], [4, 5, 6])
      %ZipperList{left: [3, 2, 1], cursor: 4, right: [5, 6]}

      iex> ZipperList.to_list(%ZipperList{left: [3, 2, 1], cursor: 4, right: [5, 6]})
      [1, 2, 3, 4, 5, 6]

  ## Reference

  See the Wikipidia article "[Zipper_data
  structure](https://en.wikipedia.org/wiki/ZipperList_\(data_structure\))" for
  more (mathematically complicated) information.
  """
  @type t :: %ZipperList{left: list, cursor: any, right: list}
  defstruct left: [], cursor: nil, right: []


  @doc """
  Returns an empty ZipperList with the cursor position at the front.

  ## Examples

      iex> ZipperList.empty
      %ZipperList{left: [], cursor: nil, right: []}
  """
  @spec empty :: ZipperList.t
  def empty, do: %ZipperList{}


  @doc """
  Returns a new ZipperList with the cursor from `ZipperList.right`'s first
  element.

  ## Examples

      iex> ZipperList.from_lists([1, 2, 3], [4, 5])
      %ZipperList{left: [3, 2, 1], cursor: 4, right: [5]}
  """
  @spec from_lists(list, list) :: ZipperList.t
  def from_lists(left, [c | right]) do
    %ZipperList{left: Enum.reverse(left), cursor: c, right: right}
  end


  @doc """
  Returns a zipper containing the elements of `xs`, with the cursor at the first
  element.

  ## Examples

      iex> ZipperList.from_list([1, 2, 3])
      %ZipperList{left: [], cursor: 1, right: [2, 3]}
  """
  @spec from_list(list) :: ZipperList.t
  def from_list([c | xs]), do: %ZipperList{right: xs, cursor: c}


  @doc """
  Returns a zipper containing the elements of `xs`, focused just off the right
  end of the list.

  ## Examples

      iex> zip = ZipperList.from_list_end([1, 2, 3])
      %ZipperList{left: [3, 2, 1], cursor: nil, right: []}
      iex> ZipperList.end? zip
      true
  """
  @spec from_list_end(list) :: ZipperList.t
  def from_list_end(xs), do: %ZipperList{left: Enum.reverse(xs)}


  @doc """
  Returns a list from the zipper.

  ## Examples

      iex> ZipperList.to_list(%ZipperList{left: [3,2,1], cursor: 4, right: [5,6]})
      [1, 2, 3, 4, 5, 6]
  """
  @spec to_list(ZipperList.t) :: list
  def to_list(z = %ZipperList{}) do
    Enum.reverse(z.left) ++ [z.cursor | z.right]
  end


  @doc """
  Returns `true` if the zipper is at the start.

  ## Examples

      iex> ZipperList.beginning?(%ZipperList{left: [], cursor: 0, right: [1, 2, 3]})
      true

      iex> ZipperList.beginning?(%ZipperList{left: [2, 1], cursor: 3, right: [4]})
      false
  """
  @spec beginning?(ZipperList.t) :: boolean
  def beginning?(%ZipperList{left: []}), do: true
  def beginning?(%ZipperList{}), do: false


  @doc """
  Returns `true` if the zipper is at the end.

  ## Examples

      iex> ZipperList.end?(%ZipperList{left: [3, 2, 1], cursor: nil, right: []})
      true

      iex> ZipperList.end?(%ZipperList{left: [2, 1], cursor: 3, right: [4]})
      false
  """
  @spec end?(ZipperList.t) :: boolean
  def end?(%ZipperList{cursor: nil, right: []}), do: true
  def end?(%ZipperList{}), do: false


  @doc """
  Returns `true` if the zipper is empty.

  ## Examples

      iex> ZipperList.empty?(ZipperList.empty)
      true

      iex> ZipperList.empty?(%ZipperList{left: [3, 2, 1], cursor: 4})
      false
  """
  @spec empty?(ZipperList.t) :: boolean
  def empty?(%ZipperList{left: [], cursor: nil, right: []}), do: true
  def empty?(%ZipperList{}), do: false


  @doc """
  Returns the zipper with the cursor set to the start. O(1)

  ## Examples

      iex> ZipperList.cursor_start(%ZipperList{left: [2, 1], cursor: 3, right: [4]})
      %ZipperList{left: [], cursor: 1, right: [2, 3, 4]}
  """
  @spec cursor_start(ZipperList.t) :: ZipperList.t
  def cursor_start(z = %ZipperList{left: [], right: []}), do: z
  def cursor_start(z = %ZipperList{}) do
    [cursor | right] = Enum.reverse(z.left) ++ [z.cursor | z.right]
    %ZipperList{cursor: cursor, right: right}
  end


  @doc """
  Returns the zipper with the cursor set to the end. `cursor` will be nil. O(1)

  ## Examples

      iex> ZipperList.cursor_end(%ZipperList{left: [2, 1], cursor: 3, right: [4, 5]})
      %ZipperList{left: [5, 4, 3, 2, 1], cursor: nil, right: []}
  """
  @spec cursor_end(ZipperList.t) :: ZipperList.t
  def cursor_end(z = %ZipperList{left: [], right: []}), do: z
  def cursor_end(z = %ZipperList{right: []}), do: z
  def cursor_end(z = %ZipperList{}) do
    %ZipperList{cursor: nil, left: Enum.reverse(z.right) ++ [z.cursor | z.left]}
  end


  @doc """
  Returns the cursor or returns the default option if the cursor is nil.

  ## Examples

      iex> ZipperList.safe_cursor(ZipperList.empty, 5)
      %ZipperList{left: [], cursor: 5, right: []}

      iex> ZipperList.safe_cursor(%ZipperList{cursor: 10}, 5)
      %ZipperList{cursor: 10}
  """
  @spec safe_cursor(ZipperList.t, any()) :: ZipperList.t
  def safe_cursor(z = %ZipperList{cursor: nil}, default) do
    %{z | cursor: default}
  end
  def safe_cursor(z = %ZipperList{}, _default), do: z


  @doc """
  Returns the zipper with the cursor focus shifted one element to the left, or
  `zipper` if the cursor is already at the beginning.

  Use `ZipperList.begin?` to check if the zipper is at the beginning.

  ## Examples

      iex> ZipperList.left(%ZipperList{left: [2, 1], cursor: 3, right: [4]})
      %ZipperList{left: [1], cursor: 2, right: [3, 4]}

      iex> ZipperList.left(%ZipperList{left: [], cursor: 1, right: [2, 3]})
      %ZipperList{left: [], cursor: 1, right: [2, 3]}
  """
  @spec left(ZipperList.t) :: ZipperList.t
  def left(z = %ZipperList{left: []}), do: z
  def left(z = %ZipperList{left: [head | tail]}) do
    %ZipperList{cursor: head, left: tail, right: [z.cursor | z.right]}
  end


  @doc """
  Returns the zipper with the cursor focus shifted one element to the right, or
  returns `zipper` if the cursor is past the end.

  Use `ZipperList.end?` to check if the zipper is at the end.

  ## Examples

  The cursor moves out of the `right` list:

      iex> ZipperList.right(%ZipperList{left: [2, 1], cursor: 3, right: [4, 5]})
      %ZipperList{left: [3, 2, 1], cursor: 4, right: [5]}

  If it is on the last item, `cursor` will be `nil`.

      iex> ZipperList.right(%ZipperList{left: [3, 2, 1], cursor: 4, right: []})
      %ZipperList{left: [4, 3, 2, 1], cursor: nil, right: []}

  If the cursor is at the end, `right` returns the zipper:

      iex> ZipperList.right(%ZipperList{left: [4, 3, 2, 1], cursor: nil, right: []})
      %ZipperList{left: [4, 3, 2, 1], cursor: nil, right: []}
  """
  @spec right(ZipperList.t) :: ZipperList.t
  def right(z = %ZipperList{cursor: nil, right: []}), do: z
  def right(z = %ZipperList{cursor: cursor, right: []}) do
    %{z | cursor: nil, left: [cursor | z.left]}
  end
  def right(z = %ZipperList{right: [head | tail]}) do
    %ZipperList{cursor: head, left: [z.cursor | z.left], right: tail}
  end


  @doc """
  Inserts `value` at the cursor position, pushing the current cursor and all
  values to the right.

  ## Examples

  Inserting a value replaces the cursor:

      iex> ZipperList.insert(%ZipperList{left: [1], cursor: 2, right: [3]}, 5)
      %ZipperList{left: [1], cursor: 5, right: [2, 3]}

  On empty zippers, it inserts at the cursor position:

      iex> ZipperList.insert(ZipperList.empty, 5)
      %ZipperList{left: [], cursor: 5, right: []}

  Any values are pushed to the right:

      iex> ZipperList.insert(%ZipperList{left: [], cursor: 5, right: []}, 10)
      %ZipperList{left: [], cursor: 10, right: [5]}
  """
  @spec insert(ZipperList.t, any) :: ZipperList.t
  def insert(z = %ZipperList{cursor: nil}, value), do: %{z | cursor: value}
  def insert(z = %ZipperList{right: right}, value) do
    %{z | cursor: value, right: [z.cursor | right]}
  end


  @doc """
  Drops the value in the cursor and replaces it with the next value from the
  right.

  ## Examples

      iex> ZipperList.delete(%ZipperList{left: [3], cursor: 4, right: [5, 2]})
      %ZipperList{left: [3], cursor: 5, right: [2]}

      iex> ZipperList.delete(ZipperList.empty)
      %ZipperList{left: [], cursor: nil, right: []}

  If there is no value to the right, `cursor` will be `nil`:

      iex> ZipperList.delete(%ZipperList{left: [2, 5, 3], cursor: 8, right: []})
      %ZipperList{left: [2, 5, 3], cursor: nil, right: []}
  """
  @spec delete(ZipperList.t) :: ZipperList.t
  def delete(z = %ZipperList{cursor: nil}), do: z
  def delete(z = %ZipperList{cursor: _c, right: []}) do
    %{z | cursor: nil}
  end
  def delete(z = %ZipperList{right: [cursor | right]}) do
    %{z | cursor: cursor, right: right}
  end


  @doc """
  Pushes a value into the position before the cursor, leaving the cursor
  unchanged.

  ## Examples

      iex> ZipperList.push(%ZipperList{left: [1], cursor: 2, right: [3, 4]}, 5)
      %ZipperList{left: [5, 1], cursor: 2, right: [3, 4]}
      iex> ZipperList.push(ZipperList.empty, 5)
      %ZipperList{left: [5], cursor: nil, right: []}
  """
  @spec push(ZipperList.t, any) :: ZipperList.t
  def push(z = %ZipperList{left: left}, value) do
    %{z | left: [value | left]}
  end


  @doc """
  Pops a value off of the position before the cursor. If there are no values to
  the left of the cursor, it returns `zipper`.

  ## Examples

      iex> ZipperList.pop(%ZipperList{left: [1], cursor: 2, right: [3, 4]})
      %ZipperList{left: [], cursor: 2, right: [3, 4]}

      iex> ZipperList.pop(ZipperList.empty)
      %ZipperList{left: [], cursor: nil, right: []}
  """
  @spec pop(ZipperList.t) :: ZipperList.t
  def pop(z = %ZipperList{left: []}), do: z
  def pop(z = %ZipperList{left: [_ | left]}) do
    %{z | left: left}
  end


  @doc """
  Replaces the zipper's cursor with the passed in `value`. If there is no
  current cursor, the value becomes the new cursor.

  ## Examples

      iex> ZipperList.replace(%ZipperList{left: [1], cursor: 2, right: [3, 4]}, 5)
      %ZipperList{left: [1], cursor: 5, right: [3, 4]}

      iex> ZipperList.replace(ZipperList.empty, 5)
      %ZipperList{left: [], cursor: 5, right: []}
  """
  @spec replace(ZipperList.t, any) :: ZipperList.t
  def replace(z = %ZipperList{}, value) do
    %{z | cursor: value}
  end


  @doc """
  Returns the zipper with the elements in the reverse order. O(1).

  The cursor "position" is shifted, but the value does not change. If the cursor
  was at the start, it's now at the end, and if it was at the end, it's now at
  the start.

  ## Examples

      iex> ZipperList.reverse(%ZipperList{left: [2, 1], cursor: 3, right: [4]})
      %ZipperList{left: [4], cursor: 3, right: [2, 1]}

      iex> ZipperList.reverse(%ZipperList{left: [], cursor: 1, right: [2, 3, 4]})
      %ZipperList{left: [2, 3, 4], cursor: 1, right: []}
  """
  @spec reverse(ZipperList.t) :: ZipperList.t
  def reverse(z = %ZipperList{left: left, right: right}) do
    %{z | left: right, right: left}
  end


  @doc """
  Returns the count of the number of elements in the zipper, including the
  cursor.

  ## Examples

      iex> ZipperList.count(%ZipperList{left: [2, 1], cursor: 3, right: [4, 5]})
      5
  """
  @spec count(ZipperList.t) :: integer
  def count(%ZipperList{left: [], cursor: nil, right: []}), do: 0
  def count(%ZipperList{left: left, cursor: nil, right: []}), do: length(left)
  def count(%ZipperList{left: left, cursor: _c, right: right}) do
    length(left) + length(right) + 1
  end
end
