defmodule Memorable.MixProject do
  use Mix.Project

  def project do
    [
      app: :memorable,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "memorable",
      source_url: "https://github.com/canidae-solutions/memorable",
      docs: &docs/0
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Memorable, []},
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      main: "Memorable",
      extras: ["README.md"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:memento, "~> 0.5.0"},
      {:plug, "~> 1.17.0"},
      {:plug_cowboy, "~> 2.0"},
      {:rustler, "~> 0.36.1"},
      {:uniq, "~> 0.6.1"}
    ]
  end
end
