require 'test_helper'

class LoginTest < AcceptanceTest
  it "should display the user's name when logging in", js: true do
    set_show Fabricate(:show)

    user = Fabricate(:user)
    log_user_in user

    must_have_content user.name
  end
end
