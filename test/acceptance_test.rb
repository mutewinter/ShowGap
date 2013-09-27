# Acceptance test used for Capybara-based tests drien by minitest.

class AcceptanceTest < MiniTest::Spec
  include Capybara::RSpecMatchers
  include Capybara::DSL
  include Capybara::Screenshot

  before :each do
    DatabaseCleaner.start

    if metadata[:js]
      Capybara.current_driver = Capybara.javascript_driver
    else
      Capybara.current_driver = Capybara.default_driver
    end
  end

  def teardown
    DatabaseCleaner.clean
    Capybara.reset_sessions!    # Forget the (simulated) browser state
  end

  # -----------------------
  # Helpers
  # -----------------------

  def set_subdomain(subdomain)
    Capybara.app_host = "http://#{subdomain}.showgap.dev:#{Capybara.server_port}"
  end

  # Public: Sets the user's credentials that will be returned by OmniAuth.
  # Since the user's own credentials are overridden by whatever is returned by
  # OmniAuth, this should usually be set before the user logs in.
  #
  # Returns nothing.
  def set_omniauth_user(user)
    # Setup OmniAuth to return the correct metatda for this user.
    OmniAuth.config.add_mock(:twitter, {
      uid: user.uid,
      info: {
        name: user.name
      }
    })
  end

  # Public: Helper that sets the Capybara subdomain to to the subdomain for the
  # given show
  #
  # Returns nothing.
  def set_show(show)
    # Set the subdomain to the show's subdomain that was generated for this
    # test
    set_subdomain show.subdomain
  end

  # Public: Logs the given user in using Capybara.
  #
  # Returns nothing.
  def log_user_in(user)
    set_omniauth_user user
    visit '/'
    click_link 'Log In'
  end
end
