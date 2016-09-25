defmodule ZipperList.Mixfile do
  use Mix.Project

  def project do
    [app: :zipper_list,
     version: "1.1.1",
     elixir: "~> 1.3",
     docs: [extras: docs(), main: "readme"],
     package: package(),
     deps: deps(),
     description: description(),
     homepage_url: "https://github.com/bbugh/zipper_list",
     source_url: "https://github.com/bbugh/zipper_list",
     default_task: "test",
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
   ]
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
    Elixir implementation of a zipper for List.
    """
  end

  defp docs do
    ["README.md": [title: "Readme"],
     "CHANGELOG.md": [title: "Changelog"]]
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
      {:credo, "~> 0.4", only: :dev},
      {:ex_guard, "~> 1.1.1", only: :dev},
      {:excoveralls, "~> 0.5", only: :test},
      {:ex_doc, "~> 0.12", only: :dev}
    ]
  end
end
