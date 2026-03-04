defmodule NasaFuelWeb.PageControllerTest do
  use NasaFuelWeb.ConnCase

  test "GET / redirects to LiveView", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "NASA Fuel Calculator"
  end
end
