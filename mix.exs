defmodule Noumenon.MixProject do
  use Mix.Project

  def project do
    [
      app: :noumenon,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Noumenon.Application, []}
    ]
  end

  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
