defmodule Hexview.Package do
  @package_directory "priv/packages/"

  def list_files(package) do
    {:ok, files} = File.ls(path(package))
    Enum.map(files, &to_map/1)
  end

  def list_files(package, dir) do
    {:ok, files} = File.ls(path(package, dir))
    Enum.map(files, &to_map/1)
  end

  defp to_map(path) do
    %{
      name: path,
      is_directory: File.dir?(path),
    }
  end

  def fetch_file(package, dir) do
    {:ok, binary} = File.read(path(package, dir))

    %{name: Path.basename(dir), content: binary}
  end

  defp path(package), do: "#{@package_directory}/#{package}"
  defp path(package, dir), do: "#{@package_directory}/#{package}/#{dir}"
end
