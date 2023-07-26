defmodule PostFinanceScraperWeb.ErrorJSONTest do
  use PostFinanceScraperWeb.ConnCase, async: true

  test "renders 404" do
    assert PostFinanceScraperWeb.ErrorJSON.render("404.json", %{}) == %{
             errors: %{detail: "Not Found"}
           }
  end

  test "renders 500" do
    assert PostFinanceScraperWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
