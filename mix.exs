defmodule ZipperList.Mixfile do
  use Mix.Project

  def project do
    [app: :zipper_list,
     version: "0.9.0-beta3",
     elixir: "~> 1.3",
     docs: [extras: docs()],
     package: package(),
     deps: deps(),
     description: description(),
     homepage_url: "https://github.com/bbugh/zipper_list",
     source_url: "https://github.com/bbugh/zipper_list",
     default_task: "test"]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: []]
  end

  defp package do
    [
      description: description(),
      maintainers: ["Brian Bugh"],
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/bbugh/zipper_list"}
    ]
  end

  defp description do
    """
    A Haskell-inspired implementation of a zipper list data structure.

    Uses a flat 2D List structure with a cursor node and left/right O(1)
    traversal.

    For more information on zippers, visit
    [Zipper_(data_structure)](https://en.wikipedia.org/wiki/ZipperList_\(data_structure\))
    """
  end

  defp docs do
    ["README.md": [title: "Readme"]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:ex_guard, "~> 1.1.1", only: :dev},
      {:ex_doc, "~> 0.12", only: :dev}
    ]
  end
end
