class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_for_stub

  def default_url_options
    if Rails.env.production?
      {host: "paywith.me"}.merge(super)
    else
      {host: "localhost:3000"}.merge(super)
    end
  end

private
  def check_for_stub
    if params[:token]
      user = User.find_by_guest_token(params[:token])
      if user.present?
        session[:user_return_to] = request.url
        if user.stub?
          sign_in user
          @display_stub_login = true
        else
          redirect_to new_user_session_path
        end
      else
        flash[:error] = "Invalid login token."
        redirect_to root_path
      end
    end
  end
end