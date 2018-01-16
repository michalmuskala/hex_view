defmodule HexviewWeb.PackageView do
  use HexviewWeb, :view

  def file_path(%{"path" => path}, filename) do
    path ++ [filename]
  end
  # def file_path(_params, filename), do: filename
  def file_path(_params, filename) do
    [filename]
  end
end
