defmodule HexviewWeb.PackageController do
  use HexviewWeb, :controller

  alias Hexview.Package

  def show(conn, %{"name" => name}) do
    files = Package.list_files(name)
    render conn, "show.html", name: name, files: files
  end
end
