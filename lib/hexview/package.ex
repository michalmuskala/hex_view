defmodule Hexview.Package do
  @package_directory "db/hex_packages"

  alias Hexview.API.Tarballs

  # HACK
  def list_files(package, version) do
    {:ok, files} = File.ls(path(package, version))
    Enum.map(files, fn file -> to_map(package, version, file) end)
  end

  def list_files(package, version, dir) do
    {:ok, files} = File.ls(path(package, version, dir))
    Enum.map(files, fn file -> to_map(package, version, dir, file) end)
  end

  # HACK
  defp to_map(package, version, filename) do
    %{
      name: filename,
      is_directory: File.dir?(path(package, version, filename)),
    }
  end

  defp to_map(package, version, dir, filename) do
    %{
      name: filename,
      is_directory: File.dir?(path(package, version, dir, filename)),
    }
  end

  def fetch_file(package, version, dir) do
    {:ok, binary} = File.read(path(package, version, dir))

    %{name: Path.basename(dir), content: binary}
  end

  # HACK
  def package_exists?(name, version) do
    # if the package hasn't been cached, try to download it.
    case Tarballs.download(name, version) do
      {:ok, {:cached, _, _}} -> true
      {:ok, {:download, _, _}} -> true

      # somethings wrong
      _ -> false
    end
  end

  # HACK
  defp path(package, version), do: "#{@package_directory}/#{package}-#{version}/src"
  defp path(package, version, dir), do: "#{@package_directory}/#{package}-#{version}/src/#{dir}"
  defp path(package, version, dir, filename), do: "#{@package_directory}/#{package}-#{version}/src/#{dir}/#{filename}"
end
