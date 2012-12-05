class ApplicationController < ActionController::Base
  protect_from_forgery

  def default_url_options
    if Rails.env.production?
      {host: "paywith.me"}.merge(super)
    else
      {host: "localhost:3000"}.merge(super)
    end
  end
end