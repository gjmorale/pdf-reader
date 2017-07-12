require 'test_helper'

class DictionaryElementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dictionary_element = dictionary_elements(:one)
  end

  test "should get index" do
    get dictionary_elements_url
    assert_response :success
  end

  test "should get new" do
    get new_dictionary_element_url
    assert_response :success
  end

  test "should create dictionary_element" do
    assert_difference('DictionaryElement.count') do
      post dictionary_elements_url, params: { dictionary_element: { dictionary_id: @dictionary_element.dictionary_id, element_id: @dictionary_element.element_id, element_type: @dictionary_element.element_type } }
    end

    assert_redirected_to dictionary_element_url(DictionaryElement.last)
  end

  test "should show dictionary_element" do
    get dictionary_element_url(@dictionary_element)
    assert_response :success
  end

  test "should get edit" do
    get edit_dictionary_element_url(@dictionary_element)
    assert_response :success
  end

  test "should update dictionary_element" do
    patch dictionary_element_url(@dictionary_element), params: { dictionary_element: { dictionary_id: @dictionary_element.dictionary_id, element_id: @dictionary_element.element_id, element_type: @dictionary_element.element_type } }
    assert_redirected_to dictionary_element_url(@dictionary_element)
  end

  test "should destroy dictionary_element" do
    assert_difference('DictionaryElement.count', -1) do
      delete dictionary_element_url(@dictionary_element)
    end

    assert_redirected_to dictionary_elements_url
  end
end
