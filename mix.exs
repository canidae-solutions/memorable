defmodule Memorable.MixProject do
  use Mix.Project

  def project do
    [
      app: :memorable,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Memorable, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:memento, "~> 0.5.0"},
      {:plug, "~> 1.17.0"},
      {:plug_cowboy, "~> 2.0"},
      {:uniq, "~> 0.6.1"}
    ]
  end
end
