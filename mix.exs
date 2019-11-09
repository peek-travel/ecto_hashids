defmodule EctoHashids.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :ecto_hashids,
      name: "Ecto Hashids",
      source_url: "https://github.com/peek-travel/ecto_hashids",
      version: @version,
      elixir: "~> 1.9",
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      dialyzer: [flags: []],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp description do
    """
    Ecto Hashids is an ecto utility to create types for your primary_keys and handle
    all dumping and casting to seamless interact w/ sequential IDs w/out ever exposing them to your users.

    This is not intended for security; guessing a hashid is as easy as guessing a sequential id.
    This is intended, instead, to help w/ the optics of exposing things like `/purchase/2` to your customers.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Greg Coladarci"],
      licenses: ["MIT"],
      links: %{GitHub: "https://github.com/peek-travel/ecto_hashids"}
    ]
  end

  defp docs do
    [
      # main: "Cocktail.Schedule",
      # logo: "logo.png",
      # source_ref: @version,
      # source_url: "https://github.com/peek-travel/cocktail",
      # extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:hashids, "~> 2.0"},
      {:ecto_sql, "~> 3.1"},
      {:excoveralls, "~> 0.7", only: :test},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_unit_notifier, "~> 0.1", only: :test}
    ]
  end
end
