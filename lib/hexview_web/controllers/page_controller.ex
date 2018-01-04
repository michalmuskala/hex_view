defmodule HexviewWeb.PageController do
  use HexviewWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
