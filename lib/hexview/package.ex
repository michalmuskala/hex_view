defmodule Hexview.Package do
  @package_directory "priv/packages/"

  def list_files(package) do
    Path.wildcard(@package_directory <> package <> "/**/*")
  end
end
