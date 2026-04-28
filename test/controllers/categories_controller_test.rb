require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  FIREFOX_USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0"
  CHROME_USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"

  test "home page is accessible from Firefox" do
    get store_index_url, headers: { "User-Agent" => FIREFOX_USER_AGENT }

    assert_response :success
  end

  test "books index returns not found for Firefox" do
    get products_url, headers: { "User-Agent" => FIREFOX_USER_AGENT }

    assert_response :not_found
  end

  test "my orders route resolves to users orders action" do
    assert_routing "/my-orders", controller: "users", action: "orders"
  end

  test "my items route resolves to users line_items action" do
    assert_routing "/my-items", controller: "users", action: "line_items"
  end

  test "books routes are accessible from non-Firefox user agents" do
    get products_url, headers: { "User-Agent" => CHROME_USER_AGENT }

    assert_response :redirect
    assert_redirected_to new_session_url
  end
end
