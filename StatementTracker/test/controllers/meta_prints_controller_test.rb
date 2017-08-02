require 'test_helper'

class MetaPrintsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meta_print = meta_prints(:one)
  end

  test "should get index" do
    get meta_prints_url
    assert_response :success
  end

  test "should get new" do
    get new_meta_print_url
    assert_response :success
  end

  test "should create meta_print" do
    assert_difference('MetaPrint.count') do
      post meta_prints_url, params: { meta_print: { bank_id: @meta_print.bank_id, creator: @meta_print.creator, producer: @meta_print.producer } }
    end

    assert_redirected_to meta_print_url(MetaPrint.last)
  end

  test "should show meta_print" do
    get meta_print_url(@meta_print)
    assert_response :success
  end

  test "should get edit" do
    get edit_meta_print_url(@meta_print)
    assert_response :success
  end

  test "should update meta_print" do
    patch meta_print_url(@meta_print), params: { meta_print: { bank_id: @meta_print.bank_id, creator: @meta_print.creator, producer: @meta_print.producer } }
    assert_redirected_to meta_print_url(@meta_print)
  end

  test "should destroy meta_print" do
    assert_difference('MetaPrint.count', -1) do
      delete meta_print_url(@meta_print)
    end

    assert_redirected_to meta_prints_url
  end
end
