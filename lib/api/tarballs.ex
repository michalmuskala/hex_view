defmodule Hexview.API.Tarballs do
  @moduledoc """
  A GenServer, for downloading package files
  """

  use GenServer

  @baseurl "https://repo.hex.pm/tarballs/"
  @hex_tarballs "db/hex_tarballs"
  @hex_packages "db/hex_packages"

  def init(args) do
    :inets.start()
    :ets.new(:hex_tarballs, [:set, :protected, :named_table])

    scan_disk()

    {:ok, args}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Download a special version package into db/hex_tarballs/ directory

  If cached, never download again.

      Hexview.API.Tarballs.download("ecto", "2.2.7")
  """
  def download(name, version) do
    if cached?(name, version) do
      {:ok, "but we have cached #{name}-#{version}.tar"}
    else
      GenServer.cast(__MODULE__, {:download, {name, version}})
    end
  end

  @doc """
  check a special version pacakge

  If cached, return true. Otherwise, false.

      Hexview.API.Tarballs.cached?("ecto", "2.2.7")
  """
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

    File.write!(Path.join(@hex_tarballs, tar), body)

    :ets.insert(:hex_tarballs, {rootname, true})

    extract_compressed_file(tar)

    {:noreply, state}
  end

  defp scan_disk() do
    case File.ls(@hex_tarballs) do
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

  # TODO move into a seperate GenServer
  defp extract_compressed_file(file) do
    :erl_tar.extract(Path.join([@hex_tarballs, file]), [
      {:cwd, Path.join([@hex_packages, Path.rootname(file)])}
    ])

    :erl_tar.extract(Path.join([@hex_packages, Path.rootname(file), "contents.tar.gz"]), [
      :compressed,
      {:cwd, Path.join([@hex_packages, Path.rootname(file), "src"])}
    ])
  end
end
