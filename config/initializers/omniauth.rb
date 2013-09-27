Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['SHOWGAP_TWITTER_KEY'], ENV['SHOWGAP_TWITTER_SECRET']
end
