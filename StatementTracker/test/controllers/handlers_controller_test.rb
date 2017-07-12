require 'test_helper'

class HandlersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @handler = handlers(:one)
  end

  test "should get index" do
    get handlers_url
    assert_response :success
  end

  test "should get new" do
    get new_handler_url
    assert_response :success
  end

  test "should create handler" do
    assert_difference('Handler.count') do
      post handlers_url, params: { handler: { local_path: @handler.local_path, name: @handler.name, repo_path: @handler.repo_path, short_name: @handler.short_name } }
    end

    assert_redirected_to handler_url(Handler.last)
  end

  test "should show handler" do
    get handler_url(@handler)
    assert_response :success
  end

  test "should get edit" do
    get edit_handler_url(@handler)
    assert_response :success
  end

  test "should update handler" do
    patch handler_url(@handler), params: { handler: { local_path: @handler.local_path, name: @handler.name, repo_path: @handler.repo_path, short_name: @handler.short_name } }
    assert_redirected_to handler_url(@handler)
  end

  test "should destroy handler" do
    assert_difference('Handler.count', -1) do
      delete handler_url(@handler)
    end

    assert_redirected_to handlers_url
  end
end
