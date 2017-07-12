require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get test" do
    get static_pages_test_url
    assert_response :success
  end

end
