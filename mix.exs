defmodule Mock.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [ app: :ex_mock,
      name: "ExMock",
      version: @version,
      elixir: "~> 1.0",
      elixirc_paths: elixirc_paths(Mix.env),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      docs: [source_ref: "v#{@version}", main: "ExMock"],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test],
      deps: deps() ]
  end

  defp deps do
    [
      {:meck, "~> 0.8.2"},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp description do
    """
    A mocking libary for the Elixir language.

    We use the Erlang meck library to provide module mocking
    functionality for Elixir. It uses macros in Elixir to expose
    the functionality in a convenient manner for integrating in
    Elixir tests.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      contributors: [
        "Happy"
      ],
      maintainers: ["Happy"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/gialib/exmock"
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
