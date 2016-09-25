defmodule ZipperListTest do
  use ExUnit.Case
  doctest ZipperList
  doctest Enumerable.ZipperList
  import ExUnit.CaptureIO

  describe "cursor_start" do
    test "when nothing on the left or right, it returns the zipper" do
      zs = %ZipperList{left: [], cursor: 8, right: []}
      assert zs == ZipperList.cursor_start(zs)

      zs = %ZipperList{left: [], cursor: nil, right: []}
      assert zs == ZipperList.cursor_start(zs)
    end
  end

  describe "cursor_end" do
    test "when nothing on the right, it returns the zipper" do
      zs = %ZipperList{left: [3, 2, 1], cursor: 4, right: []}
      assert zs == ZipperList.cursor_end(zs)
    end

    test "when nothing on the left or right, it returns the zipper" do
      zs = %ZipperList{left: [], cursor: 8, right: []}
      assert zs == ZipperList.cursor_end(zs)
    end

    test "when the zipper is empty, it returns2" do
      zs = %ZipperList{left: [], right: []}
      assert zs == ZipperList.cursor_end(zs)
    end

    test "when the zipper is empty, it returns" do
      zs = %ZipperList{left: [], cursor: nil, right: []}
      assert zs == ZipperList.cursor_end(zs)
    end
  end

  describe "count" do
    test "returns 0 for empty zippers" do
      assert 0 == ZipperList.count(ZipperList.empty)
    end

    test "returns correctly at end of zipper" do
      zs = %ZipperList{left: [5, 4, 3, 2, 1], cursor: nil, right: []}
      assert 5 == ZipperList.count(zs)
    end
  end

  describe "left" do
    test "when at end of list, doesn't add nil to right" do
      zs = %ZipperList{left: [3, 2, 1], cursor: nil, right: []}
      expected = %ZipperList{left: [2, 1], cursor: 3, right: []}
      assert expected == ZipperList.left(zs)
    end

    test "only trims nil when it's at the end" do
      zs = %ZipperList{left: [3, nil, 2, 1], cursor: nil, right: [3]}
      expected = %ZipperList{left: [nil, 2, 1], cursor: 3, right: [nil, 3]}
      assert expected == ZipperList.left(zs)
    end

    test "trims nils each time with contrived nil ZipperList" do
      zs = %ZipperList{left: [nil, nil], cursor: nil, right: []}
      expected = ZipperList.empty
      assert expected == zs |> ZipperList.left |> ZipperList.left
    end
  end

  describe "Enum.count" do
    test "it counts" do
      zs = ZipperList.from_list([1, 2, 3])
      assert 3 == Enum.count(zs)

      zs = %ZipperList{right: [3], cursor: 0}
      assert 2 == Enum.count(zs)

      zs = ZipperList.from_lists([2, 3], [3, 4])
      assert 4 == Enum.count(zs)
    end
  end

  describe "Enum.member?" do
    test "finds members in the left side" do
      assert Enum.member?(%ZipperList{left: [1, 3, 5]}, 5)
    end

    test "finds members in the right side" do
      assert Enum.member?(%ZipperList{right: [1, 3, 5]}, 5)
    end

    test "finds members in the cursor" do
      assert Enum.member?(%ZipperList{cursor: 10}, 10)
    end

    test "doesn't find things that don't exist" do
      z = %ZipperList{left: [2, 1], right: [3, 4], cursor: "salad"}
      refute Enum.member?(z, "potato")
    end
  end

  describe "Enum.reduce" do
    test "it reduces the right side" do
      zs = ZipperList.from_lists([1, 2, 3], [4, 5])
      result = Enumerable.reduce(zs, {:cont, 0}, fn(z, acc) ->
        {:cont, z.cursor + acc}
      end)

      assert {:done, 9} == result
    end

    test "it only reads from the cursor position" do
      zs = ZipperList.from_lists([1, 2, 3], [4, 5])
      refute Enum.find(zs, &(&1.cursor == 2))
    end

    test "it handles :suspend" do
      zs = ZipperList.from_list([2, 3, 4])
      result = Enumerable.reduce(zs, {:cont, 5}, fn(_z, acc) ->
        {:suspend, acc}
      end)
      assert {:suspended, 5, _} = result
    end

    test "it can resume after suspend" do
      zs = ZipperList.from_lists([1], [2, 3, 4, 5])
      {:suspended, 2, continuation} = Enumerable.reduce(zs, {:cont, 0}, fn(z, acc) ->
        if z.cursor == 3 do
          {:suspend, acc}
        else
          {:cont, acc + z.cursor}
        end
      end)

      assert {:done, 13} = continuation.({:cont, 4})
    end

    test "it handles :halt" do
      zs = ZipperList.from_lists([1], [2, 3, 4, 5])
      assert {:halted, 100} = Enumerable.reduce(zs, {:cont, 100}, fn(_z, acc) ->
        {:halt, acc}
      end)
    end

    test "it can do find" do
      zs = ZipperList.from_lists([1], [2, 3, 4, 5])
      result = Enum.find(zs, &(&1.cursor == 4))
      assert result == %ZipperList{left: [3, 2, 1], right: [5], cursor: 4}
    end
  end

  describe "Inspect.inspect protocol" do
    test "prints :left before :cursor" do
      zs = %ZipperList{left: [3, 2, 1], cursor: nil, right: []}
      assert "%ZipperList{left: [3, 2, 1], cursor: nil, right: []}\n"
        == capture_io(fn -> IO.inspect(zs) end)
    end
  end

  describe "Collectable.into protocol" do
    test "creates zipperlist with list comprehension" do
      z = for x <- [1, 2, 3], into: ZipperList.empty, do: x * 2
      assert z == %ZipperList{left: [6, 4, 2], cursor: nil, right: []}
    end

    test "Enum.into works" do
      assert Enum.into([1, 2, 3], ZipperList.empty)
        == %ZipperList{left: [3, 2, 1], cursor: nil, right: []}
    end
  end
end
