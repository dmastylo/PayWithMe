class MyDevise::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    if signed_in? && current_user.stub?
      current_user.provider = request.env["omniauth.auth"].provider
      current_user.uid = request.env["omniauth.auth"].uid
      current_user.name = request.env["omniauth.auth"].info.name if request.env["omniauth.auth"].info.name
      current_user.email = request.env["omniauth.auth"].info.email if request.env["omniauth.auth"].info.email
      current_user.save
      user = current_user
    else
      user = User.from_omniauth(request.env["omniauth.auth"])
    end

    if user.persisted?
      if signed_in? && current_user.stub?
        current_user.toggle(:stub)
        current_user.guest_token = nil
        current_user.save
        flash.success = "Account registration successfully completed!"
      else
        flash.notice = "Signed in successfully."
      end
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_path
    end
  end

  alias_method :twitter, :all
  alias_method :facebook, :all
end