require 'test_helper'

class LocationControllerTest < ActionDispatch::IntegrationTest
  test "should get search" do
    get location_search_url
    assert_response :success
  end

end
