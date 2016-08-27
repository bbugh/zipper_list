defmodule Zipper.Mixfile do
  use Mix.Project

  def project do
    [app: :zipper,
     version: "1.0.0-beta1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     docs: [extras: docs()],
     package: package,
     deps: deps(),
     default_task: "test"]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp package do
    [
      description: description(),
      maintainers: ["Brian Bugh"],
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/bbugh/elixir-zipper"}
    ]
  end

  defp description do
    """
    A Haskell-inspired implementation of a Zipper list.

    Uses a flat 2D structure with a cursor node and left/right traversal.

    For more information on Zipper trees, visit [Zipper_(data_structure)](https://en.wikipedia.org/wiki/Zipper_\(data_structure\))
    """
  end

  defp docs do
    ["README.md"]
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
      {:ex_doc, "~> 0.12", only: :dev}
    ]
  end
end
