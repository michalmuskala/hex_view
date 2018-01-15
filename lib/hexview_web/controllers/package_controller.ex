defmodule HexviewWeb.PackageController do
  use HexviewWeb, :controller

  plug :check_package when not action in [:index]

  alias Hexview.Package
  alias Hexview.API.Registry

  def index(conn, _params) do
    packages = Registry.all
    render conn, "index.html", packages: packages
  end

  def show(conn, %{"name" => name, "version" => version}) do
    files = Package.list_files(name, version)
    render conn, "show.html", name: name, version: version, files: files
  end

  def tree(conn, %{"name" => name, "version" => version, "path" => path}) do
    files = Package.list_files(name, version, Enum.join(path, "/"))
    render conn, "show.html", name: name, version: version, files: files
  end

  def blob(conn, %{"name" => name, "version" => version, "path" => path}) do
    file = Package.fetch_file(name, version, Enum.join(path, "/"))
    render conn, "blob.html", file: file
  end

  defp check_package(conn, _) do
    if Package.package_exists?(conn.params["name"], conn.params["version"]) do
      conn
    else
      conn
      |> put_flash(:error, "Package not found.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
