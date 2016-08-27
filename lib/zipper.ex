defmodule Zipper do
  @moduledoc """
  A Haskell-inspired Zipper list implementation.
  """
  @type t :: %Zipper{left: list, right: list, cursor: any}
  defstruct left: [], right: [], cursor: nil


  @doc """
  Returns an empty Zipper with the cursor position at the front.

  ## Examples

      iex> Zipper.empty
      %Zipper{left: [], right: [], cursor: nil}
  """
  @spec empty :: Zipper.t
  def empty, do: %Zipper{}


  @doc """
  Returns a new Zipper with the cursor from `Zipper.right`'s first element.

  ## Examples

      iex> Zipper.from_lists([1, 2, 3], [4, 5])
      %Zipper{left: [3, 2, 1], right: [5], cursor: 4}
  """
  @spec from_lists(list, list) :: Zipper.t
  def from_lists(left, [c | right]) do
    %Zipper{left: Enum.reverse(left), right: right, cursor: c}
  end


  @doc """
  Returns a zipper containing the elements of `xs`, with the cursor from the
  first element.

  ## Examples

      iex> Zipper.from_list([1, 2, 3])
      %Zipper{left: [], cursor: 1, right: [2, 3]}
  """
  @spec from_list(list) :: Zipper.t
  def from_list([c | xs]), do: %Zipper{right: xs, cursor: c}


  @doc """
  Returns a zipper containing the elements of `xs`, focused just off the right
  end of the list

  ## Examples

      iex> zip = Zipper.from_list_end([1, 2, 3])
      %Zipper{left: [3, 2, 1], right: [], cursor: nil}
      iex> Zipper.end? zip
      true
  """
  @spec from_list_end(list) :: Zipper.t
  def from_list_end(xs), do: %Zipper{left: Enum.reverse(xs)}


  @doc """
  Returns a list from the zipper, including cursor value.

  ## Examples

      iex> Zipper.to_list(%Zipper{left: [3,2,1], right: [5,6], cursor: 4})
      [1, 2, 3, 4, 5, 6]
  """
  @spec to_list(Zipper.t) :: list
  def to_list(z = %Zipper{}) do
    Enum.reverse(z.left) ++ [z.cursor | z.right]
  end


  @doc """
  Returns `true` if the zipper is at the start.

  ## Examples

      iex> Zipper.beginning?(%Zipper{left: [], right: [1, 2, 3], cursor: 0})
      true

      iex> Zipper.beginning?(%Zipper{left: [2, 1], right: [4], cursor: 3})
      false
  """
  @spec beginning?(Zipper.t) :: boolean
  def beginning?(%Zipper{left: []}), do: true
  def beginning?(%Zipper{}), do: false


  @doc """
  Returns `true` if the zipper is at the end.

  ## Examples

      iex> Zipper.end?(%Zipper{left: [3, 2, 1], right: [], cursor: nil})
      true

      iex> Zipper.end?(%Zipper{left: [2, 1], right: [4], cursor: 3})
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
  def empty?(%Zipper{left: [], right: [], cursor: nil}), do: true
  def empty?(%Zipper{}), do: false


  @doc """
  Returns the zipper with the cursor set to the start.

  ## Examples

      iex> Zipper.cursor_start(%Zipper{left: [2, 1], right: [4], cursor: 3})
      %Zipper{left: [], right: [2, 3, 4], cursor: 1}
  """
  @spec cursor_start(Zipper.t) :: Zipper.t
  def cursor_start(z = %Zipper{left: [], right: []}), do: z
  def cursor_start(z = %Zipper{}) do
    [cursor | right] = Enum.reverse(z.left) ++ [z.cursor | z.right]
    %Zipper{cursor: cursor, right: right}
  end


  @doc """
  Returns the zipper with the cursor set just after the end.

  ## Examples

      iex> Zipper.cursor_end(%Zipper{left: [2, 1], right: [4, 5], cursor: 3})
      %Zipper{left: [5, 4, 3, 2, 1], right: [], cursor: nil}
  """
  @spec cursor_end(Zipper.t) :: Zipper.t
  def cursor_end(z = %Zipper{right: []}), do: z
  def cursor_end(z = %Zipper{left: [], right: []}), do: z
  def cursor_end(z = %Zipper{}) do
    %Zipper{cursor: nil, left: Enum.reverse(z.right) ++ [z.cursor | z.left]}
   end


  @doc """
  Returns the zipper with the cursor focus shifted one element to the left, or
  the zipper if the cursor is already at the beginning.

  Use `Zipper.begin?` to check if the zipper is at the beginning.

  ## Examples

      iex> Zipper.left(%Zipper{left: [2, 1], right: [4], cursor: 3})
      %Zipper{left: [1], right: [3, 4], cursor: 2}

      iex> Zipper.left(%Zipper{left: [], right: [2, 3], cursor: 1})
      %Zipper{left: [], right: [2, 3], cursor: 1}
  """
  @spec left(Zipper.t) :: Zipper.t
  def left(z = %Zipper{left: []}), do: z
  def left(z = %Zipper{left: [head | tail]}) do
    %Zipper{cursor: head, left: tail, right: [z.cursor | z.right]}
  end


  @doc """
  Returns the zipper with the cursor focus shifted one element to the right, or
  returns the zipper if the cursor is past the end.

  Use `Zipper.end?` to check if the zipper is at the end.

  ## Examples

  The cursor moves out of the `right` list:

      iex> Zipper.right(%Zipper{left: [2, 1], right: [4, 5], cursor: 3})
      %Zipper{left: [3, 2, 1], right: [5], cursor: 4}

  If it is on the last item, `cursor` will be `nil`.

      iex> Zipper.right(%Zipper{left: [3, 2, 1], right: [], cursor: 4})
      %Zipper{left: [4, 3, 2, 1], right: [], cursor: nil}

  If the cursor is at the end, `right` returns the zipper:

      iex> Zipper.right(%Zipper{left: [4, 3, 2, 1], right: [], cursor: nil})
      %Zipper{left: [4, 3, 2, 1], right: [], cursor: nil}
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
  Inserts `value` at the cursor position, moving the current cursor to the right.

  ## Examples

  Inserting a value replaces the cursor:

      iex> Zipper.insert(%Zipper{left: [1], right: [3], cursor: 2}, 5)
      %Zipper{left: [1], right: [2, 3], cursor: 5}

  On empty zippers, it inserts at the cursor position:

      iex> Zipper.insert(Zipper.empty, 5)
      %Zipper{left: [], right: [], cursor: 5}

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
  Deletes the value at the cursor position and replaces the cursor with the next
  value from the right.

  ## Examples

      iex> Zipper.delete(%Zipper{left: [3], right: [5, 2], cursor: 4})
      %Zipper{left: [3], right: [2], cursor: 5}

      iex> Zipper.delete(Zipper.empty)
      %Zipper{left: [], right: [], cursor: nil}

  If there is no value to the right, `cursor` will be `nil`:

      iex> Zipper.delete(%Zipper{left: [2, 5, 3], right: [], cursor: 8})
      %Zipper{left: [2, 5, 3], right: [], cursor: nil}
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
  Pushes a value into the position before the cursor.

  Note: The cursor value does not change.

  ## Examples

      iex> Zipper.push(%Zipper{left: [1], right: [3, 4], cursor: 2}, 5)
      %Zipper{left: [5, 1], right: [3, 4], cursor: 2}
      iex> Zipper.push(Zipper.empty, 5)
      %Zipper{left: [5], right: [], cursor: nil}
  """
  @spec push(Zipper.t, any) :: Zipper.t
  def push(z = %Zipper{left: left}, value) do
    %{z | left: [value | left]}
  end


  @doc """
  Pops a value off of the position before the cursor. If used on an empty
  zipper, it returns the zipper.

  Note: the cursor value does not change.

  ## Examples

      iex> Zipper.pop(%Zipper{left: [1], right: [3, 4], cursor: 2})
      %Zipper{left: [], right: [3, 4], cursor: 2}

      iex> Zipper.pop(Zipper.empty)
      %Zipper{left: [], right: [], cursor: nil}
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

      iex> Zipper.replace(%Zipper{left: [1], right: [3, 4], cursor: 2}, 5)
      %Zipper{left: [1], right: [3, 4], cursor: 5}

      iex> Zipper.replace(Zipper.empty, 5)
      %Zipper{left: [], right: [], cursor: 5}
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

      iex> Zipper.reverse(%Zipper{left: [2, 1], right: [4], cursor: 3})
      %Zipper{left: [4], right: [2, 1], cursor: 3}

      iex> Zipper.reverse(%Zipper{left: [], right: [2, 3, 4], cursor: 1})
      %Zipper{left: [2, 3, 4], right: [], cursor: 1}
  """
  @spec reverse(Zipper.t) :: Zipper.t
  def reverse(z = %Zipper{left: left, right: right}) do
    %{z | left: right, right: left}
  end


  @doc """
  Returns the count of the number of elements in the zipper, including the
  cursor.

  ## Examples

      iex> Zipper.count(%Zipper{left: [2, 1], right: [4, 5], cursor: 3})
      5
  """
  @spec count(Zipper.t) :: integer
  def count(%Zipper{left: [], right: [], cursor: nil}), do: 0
  def count(%Zipper{left: left, right: [], cursor: nil}), do: length(left)
  def count(%Zipper{left: left, right: right, cursor: _c}) do
    length(left) + length(right) + 1
  end
end
