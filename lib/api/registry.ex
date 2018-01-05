defmodule Hexview.API.Registry do
  @moduledoc """
  A GenServer, for registry v2

  ets tuple struct: {name, retired, versions}

  * name: package name
  * retired: retired
  * versions: all versions of the package
  """

  use GenServer

  @url 'https://repo.hex.pm/versions'

  @doc """
  1. download versions file from https://repo.hex.pm/versions
  2. insert all packages meta information into ets table :hex_packages
  """
  def init(args) do
    :inets.start()
    :ets.new(:hex_packages, [:set, :protected, :named_table])

    fetch()

    {:ok, args}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  query all packages

      Hexview.API.Registry.all()
  """
  def all() do
    GenServer.call(__MODULE__, :all)
  end

  @doc """
  query package by name

      Hexview.API.Registry.find_by_name("ecto")
  """
  def find_by_name(name) do
    GenServer.call(__MODULE__, {:find_by_name, name})
  end

  @doc """
  redownload versions file, and update ets table

      Hexview.API.Registry.update_ets()
  """
  def update_ets() do
    GenServer.cast(__MODULE__, :update)
  end

  ###
  # GenServer API
  ###
  def handle_call(:all, _from, state) do
    {:reply, :ets.tab2list(:hex_packages), state}
  end

  def handle_call({:find_by_name, name}, _from, state) do
    {:reply, :ets.lookup(:hex_packages, name), state}
  end

  def handle_cast(:update, state) do
    fetch()
    {:noreply, state}
  end

  defp fetch() do
    {:ok, {{_, 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {@url, []}, [], body_format: :binary)

    :hex_registry.decode_versions(body)[:packages]
    |> Enum.each(fn %{:name => name, :retired => retired, :versions => versions} ->
      :ets.insert(:hex_packages, {name, retired, versions})
    end)
  end
end
