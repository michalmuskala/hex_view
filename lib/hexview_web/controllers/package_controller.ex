defmodule HexviewWeb.PackageController do
  use HexviewWeb, :controller

  def show(conn, %{"name" => name}) do
    render conn, "show.html", name: name
  end
end
