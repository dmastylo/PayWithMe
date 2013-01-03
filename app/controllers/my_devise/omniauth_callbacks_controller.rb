class MyDevise::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all

    if signed_in?
      if current_user.stub?
        current_user.name = request.env["omniauth.auth"].info.name if request.env["omniauth.auth"].info.name
        current_user.email = request.env["omniauth.auth"].info.email if request.env["omniauth.auth"].info.email
      end
      current_user.using_oauth = true
      current_user.save
      user = current_user
    else
      user = User.from_omniauth(request.env["omniauth.auth"])
    end

    if user.persisted?
      linked_account = user.linked_accounts.find_by_provider(request.env["omniauth.auth"].provider)
      if linked_account.present?
        linked_account.uid = request.env["omniauth.auth"].uid
        update = true
      else
        user.linked_accounts.create(provider: request.env["omniauth.auth"].provider, uid: request.env["omniauth.auth"].uid)
        update = false
      end
      user.save

      if signed_in?
        if current_user.stub?
          current_user.toggle(:stub)
          current_user.guest_token = nil
          current_user.save
          flash[:success] = "Account registration successfully completed!"
        else
          if update
            flash[:success] = "Synced account successfully updated!"
          else
            flash[:success] = "New account successfully synced!"
          end
          session["user_return_to"] = edit_user_registration_path
        end
      else
        flash[:notice] = "Signed in successfully."
      end
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      session["devise.account_attributes"] = { provider: request.env["omniauth.auth"].provider, uid: request.env["omniauth.auth"].uid }
      redirect_to new_user_registration_path
    end
  end

  alias_method :twitter, :all
  alias_method :facebook, :all
  alias_method :paypal, :all
end