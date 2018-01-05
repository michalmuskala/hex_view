defmodule Hexview.API.Tarballs do
  @moduledoc """
  A GenServer, for downloading package files
  """

  use GenServer

  @baseurl "https://repo.hex.pm/tarballs/"

  def init(args) do
    :inets.start()
    :ets.new(:hex_tarballs, [:set, :protected, :named_table])

    scan_disk()

    {:ok, args}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def download(name, version) do
    if cached?(name, version) do
      {:ok, "but we have cached #{name}-#{version}.tar"}
    else
      GenServer.cast(__MODULE__, {:download, {name, version}})
    end
  end

  def cached?(name, version) do
    case GenServer.call(__MODULE__, {:find_by_tar, {name, version}}) do
      [{_, true}] -> true
      [] -> false
    end
  end

  ###
  # GenServer API
  ###

  def handle_call({:find_by_tar, {name, version}}, _from, state) do
    {:reply, :ets.lookup(:hex_tarballs, "#{name}-#{version}"), state}
  end

  def handle_cast({:download, {name, version}}, state) do
    rootname = "#{name}-#{version}"
    tar = rootname <> ".tar"
    url = to_charlist(@baseurl <> tar)

    {:ok, {{_, 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {url, []}, [], body_format: :binary)

    File.write!("db/hex_tarballs/#{tar}", body)

    :ets.insert(:hex_tarballs, {rootname, true})

    {:noreply, state}
  end

  defp scan_disk() do
    case File.ls("db/hex_tarballs") do
      {:ok, pkgs} ->
        pkgs
        |> Enum.each(fn pkg ->
          if Path.extname(pkg) == ".tar" do
            :ets.insert(:hex_tarballs, {Path.rootname(pkg), true})
          end
        end)

      {:error, e} ->
        {:error, e}
    end
  end
end
