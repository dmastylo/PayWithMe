class AccountsController < ApplicationController
  protect_from_forgery

  def create

    # Parse the omniauth data
    @provider = request.env["omniauth.auth"].provider
    user_data = {
      provider: request.env["omniauth.auth"].provider,
      uid: request.env["omniauth.auth"].uid,
      token: request.env["omniauth.auth"].credentials.token
    }

    if ["twitter", "facebook"].include?(@provider)
      user_data.merge({
        name: request.env["omniauth.auth"].extra.raw_info.name,
        username: request.env["omniauth.auth"].info.nickname,
        email: request.env["omniauth.auth"].info.email,
      })
    end

    # Look for the user
    @user = User.find_for_oauth(request.env["omniauth.auth"], current_user)

    if signed_in?
      # We are linking a new account to an existing user that is currently signed in
      puts user_data
      
      current_user.linked_accounts << LinkedAccount.new(provider: request.env["omniauth.auth"].provider, uid: request.env["omniauth.auth"].uid, token: request.env["omniauth.auth"].credentials.token)
      current_user.save
      redirect_to users_settings_url
    elsif !@user.nil?
      # We're signing in a new user. They are already linked
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => @provider.capitalize
      sign_in_and_redirect @user, :event => :authentication
    else
      # We are creating a new user based on this login
      session["devise.user_data"] = user_data
      redirect_to new_user_registration_url
    end

  end
end