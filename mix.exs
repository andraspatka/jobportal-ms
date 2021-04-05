defmodule ApiTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :api_test,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ApiTest.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:poison, "~> 3.1"},
      {:cowboy, "~> 2.6"},
      {:plug_cowboy, "~> 2.0"},
      {:jsonapi, "~> 0.7.0"},
      {:mongodb, "~> 0.5.1"},
      {:timex, "~> 3.7.3"},
      {:pbkdf2_elixir, "~> 1.3.0"},
    ]
  end
end
