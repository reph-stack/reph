defmodule <%= web_namespace %>.ReactControllerTest do
  use <%= web_namespace %>.ConnCase

  test "/ path have index div", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ ~s(<div id="index">)
  end

  describe "Server-side rendering" do
    test "Page have element with data-reactroot attribute", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "data-reactroot"
    end
  end
end
