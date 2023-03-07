require 'test_helper'

module Authentication
  class UsersControllerTest < ActionDispatch::IntegrationTest
    test 'should get new' do
      get new_user_url
      assert_response :success
    end

    test 'should create user' do
      assert_difference('User.count') do
        post users_url, params: { user: { email: 'juan@example.com', username: 'juan09', password: 'testme' } }
      end

      assert_redirected_to weather_finder_index_url
    end
  end
end
