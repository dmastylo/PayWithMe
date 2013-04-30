class VanityController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_is_admin

  layout false

	include Vanity::Rails::Dashboard
end