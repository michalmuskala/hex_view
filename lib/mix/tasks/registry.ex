defmodule Mix.Tasks.Registry do
  @shortdoc "insert all packages and their versions into ets"

  @moduledoc """
  task:

  1. download versions file from https://repo.hex.pm/versions
  2. insert all packages meta information into ets table :hex_packages

  ets tuple struct: {name, retired, versions}

  * name: package name
  * retired: retired
  * versions: all versions of the package

  run:

      mix registry
  """

  use Mix.Task

  def run(_args) do
    url = 'https://repo.hex.pm/versions'

    :inets.start()
    {:ok, {{_, 200, 'OK'}, _headers, body}} = :httpc.request(:get, {url, []}, [], [body_format: :binary])

    :ets.new(:hex_packages, [:set, :protected, :named_table])

    :hex_registry.decode_versions(body)[:packages]
    |> Enum.each(fn (%{:name => name, :retired => retired , :versions => versions}) ->
      :ets.insert(:hex_packages, {name, retired, versions})
    end)
  end

end
