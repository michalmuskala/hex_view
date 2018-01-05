defmodule HexviewWeb.PageControllerTest do
  use HexviewWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "HexView"
  end
end
