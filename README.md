# Zipper List Library for Elixir
[![Hex Version](https://img.shields.io/badge/hex-v1.1.1-blue.svg)](https://hex.pm/packages/zipper_list/1.1.1) [![Build Status](https://travis-ci.org/bbugh/zipper_list.svg?branch=master)](https://travis-ci.org/bbugh/zipper_list) [![Coverage Status](https://coveralls.io/repos/github/bbugh/zipper_list/badge.svg?branch=master)](https://coveralls.io/github/bbugh/zipper_list?branch=master) [![license](https://img.shields.io/github/license/bbugh/zipper_list.svg?maxAge=2592000)](https://github.com/bbugh/zipper_list/blob/master/LICENSE.md)

[`zipper_list`](https://github.com/bbugh/zipper_list) is a library that
implements a flat [Zipper data
structure](https://en.wikipedia.org/wiki/Zipper_\(data_structure\)).

A zipper list allows for rapid left and right traversal on a list in constant
time O(1). Useful for cases where a simple enumeration won't work. If you have
to use [`Enum.at/2`](http://elixir-lang.org/docs/stable/elixir/Enum.html#at/3)
repeatedly, consider using `ZipperList` instead.

`ZipperList` implements `Enumerable`, so all of the standard `Enum` methods will
work with it. However, keep in mind that they begin enumerating to the right
from the cursor position, *not* the beginning of the zipper.

If you're looking for a Zipper**Tree**, check out [this
one by Dkendal](https://github.com/Dkendal/zipper_tree).

## Installation

  1. Add `zipper_list` to your list of dependencies in `mix.exs`:

  ```elixir
def deps do
  [
    {:zipper_list, "~> 1.0.0"}
  ]
end
  ```

  2. Run `mix deps.get`

  3. Ride a unicorn off into the sunset.

## Usage

Any node of the ZipperList has complete data about every other node of the list.
As you navigate the zipper, you won't lose track of ordering or state. This can
be helpful when you need to store particular locations while you're navigating.

```elixir
iex> zip = %ZipperList{left: [2, 1], cursor: 3, right: [4, 5, 6]}
```

You can access the data like any Elixir `Struct`. The `cursor` attribute is the
most important and most used. In most cases, you won't need to manually access
the `left` and `right` attributes.

```elixir
iex> zip.cursor
4
iex> zip.left
[3, 2, 1]
iex> zip.right
[5, 6]
```

### Navigation

You can pass along a ZipperList to `Zipper.right/1` and `Zipper.left/1` to
traverse the list (in constant time). Movements can be chained to repeat
navigation:

```elixir
iex> zip |> ZipperList.right
%ZipperList{left: [3, 2, 1], cursor: 4, right: [5, 6]}

iex> zip |> ZipperList.left |> ZipperList.left
%ZipperList{left: [], cursor: 1, right: [2, 3, 4, 5, 6]}
```

### Enumeration

You can also use any `Enum` method as usual. Be aware that it will enumerate
starting at the cursor and go to the right.

```elixir
iex> zip |> Enum.find(fn(z) -> z.cursor == 5 end)
%ZipperList{left: [4, 3, 2, 1], cursor: 5, right: [6]}
```

If you want to start enumerating from the beginning of the list, you can use
`ZipperList.cursor_start/1` to reset the list (in constant time).

```elixir
iex> zip |> Zipper.cursor_start |> Enum.find(fn(z) -> z.cursor == 2 end)
%ZipperList{left: [1], cursor: 2, right: [3, 4, 5, 6]}
```

Awesome, huh?

Check [the `ZipperList` API docs](https://hexdocs.pm/zipper_list/) for all the
details.

## Contributing

Bug reports, pull requests, and compliments are welcome on GitHub at
https://github.com/bbugh/elixir-zipper. If you find it useful, let me know on
[Twitter](https://twitter.com/brainbag)! I love hearing from people who use my
work.

If you're new to open source contribution, [this Beginner's Guide to
Contributing to Open Source
Projects](https://blog.newrelic.com/2014/05/05/open-source_gettingstarted/) is a
great resource.

## License

The `zipper_list` library is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT). This license means you can
use it however you want, as long as you give me credit. Especially if "credit"
is a credit line from your bank.
