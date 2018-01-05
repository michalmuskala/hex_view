defmodule HexviewWeb.PackageController do
  use HexviewWeb, :controller

  alias Hexview.Package

  def show(conn, %{"name" => name}) do
    files = Package.list_files(name)
    render conn, "show.html", name: name, files: files
  end

  def tree(conn, %{"name" => name, "path" => path}) do
    files = Package.list_files(name, Enum.join(path, "/"))
    render conn, "show.html", name: name, files: files
  end

  def blob(conn, %{"name" => name, "path" => path}) do
    file = Package.fetch_file(name, Enum.join(path, "/"))
    render conn, "blob.html", file: file
  end
end
