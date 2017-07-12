require 'test_helper'

class FileManagerControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get file_manager_update_url
    assert_response :success
  end

  test "should get new" do
    get file_manager_new_url
    assert_response :success
  end

  test "should get index" do
    get file_manager_index_url
    assert_response :success
  end

end
