defmodule Hexview.Package do
  @package_directory "db/hex_packages"

  alias Hexview.API.Tarballs

  def list_files(package, version) do
    {:ok, files} = File.ls(path(package, version))
    Enum.map(files, &to_map/1)
  end

  def list_files(package, version, dir) do
    {:ok, files} = File.ls(path(package, version, dir))
    Enum.map(files, fn file -> to_map(package, version, dir, file) end)
  end


  defp to_map(filename) do
    %{
      name: filename,
      is_directory: File.dir?(filename)
    }
  end

  defp to_map(package, version, dir, filename) do
    %{
      name: dir,
      is_directory: File.dir?(path(package, version, dir, filename)),
    }
  end

  def fetch_file(package, version, dir) do
    {:ok, binary} = File.read(path(package, version, dir))

    %{name: Path.basename(dir), content: binary}
  end

  def package_exists?(name, version) do
    if Tarballs.cached?(name, version) do
      true
    else
      case Tarballs.download(name, version) do
        {:ok, _msg} -> true
        _ -> false
      end
    end
  end

  defp path(package, version), do: "#{@package_directory}/#{package}-#{version}/src"
  defp path(package, version, dir), do: "#{@package_directory}/#{package}-#{version}/src/#{dir}"
  defp path(package, version, dir, filename), do: "#{@package_directory}/#{package}-#{version}/src/#{dir}/#{filename}"
end
