require 'test_helper'

class CoverPrintsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cover_print = cover_prints(:one)
  end

  test "should get index" do
    get cover_prints_url
    assert_response :success
  end

  test "should get new" do
    get new_cover_print_url
    assert_response :success
  end

  test "should create cover_print" do
    assert_difference('CoverPrint.count') do
      post cover_prints_url, params: { cover_print: { bank_id: @cover_print.bank_id, first_filter: @cover_print.first_filter, meta_print_id: @cover_print.meta_print_id, second_filter: @cover_print.second_filter } }
    end

    assert_redirected_to cover_print_url(CoverPrint.last)
  end

  test "should show cover_print" do
    get cover_print_url(@cover_print)
    assert_response :success
  end

  test "should get edit" do
    get edit_cover_print_url(@cover_print)
    assert_response :success
  end

  test "should update cover_print" do
    patch cover_print_url(@cover_print), params: { cover_print: { bank_id: @cover_print.bank_id, first_filter: @cover_print.first_filter, meta_print_id: @cover_print.meta_print_id, second_filter: @cover_print.second_filter } }
    assert_redirected_to cover_print_url(@cover_print)
  end

  test "should destroy cover_print" do
    assert_difference('CoverPrint.count', -1) do
      delete cover_print_url(@cover_print)
    end

    assert_redirected_to cover_prints_url
  end
end
