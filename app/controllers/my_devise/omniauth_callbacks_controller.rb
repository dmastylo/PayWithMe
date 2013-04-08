class MyDevise::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    # Used for flash messages
    provider = request.env["omniauth.auth"].provider.humanize

    if signed_in?
      # Make sure account isn't in use
      user = User.from_omniauth(request.env["omniauth.auth"])
      if user.persisted? && user != current_user
        flash[:error] = "That #{provider} account is already in use."
        redirect_to edit_user_registration_path
        return
      end

      # Set information if account is a stub
      if current_user.stub?
        current_user.name = request.env["omniauth.auth"].info.name if request.env["omniauth.auth"].info.name
        current_user.email = request.env["omniauth.auth"].info.email if request.env["omniauth.auth"].info.email
      end
      
      # Update user
      current_user.using_oauth = true
      current_user.save
      user = current_user
      new_registration = false
    else
      # Create new user or sign in existing
      user = User.from_omniauth(request.env["omniauth.auth"])
      if user.new_record?
        new_registration = true
      end
      user.save
    end

    if user.persisted?
      # Update linked accounts
      linked_account = user.linked_accounts.find_by_provider(request.env["omniauth.auth"].provider)
      if linked_account.present?
        linked_account.uid = request.env["omniauth.auth"].uid
        update = true
      else
        linked_account = user.linked_accounts.create(provider: request.env["omniauth.auth"].provider, uid: request.env["omniauth.auth"].uid)
        update = false
      end
      linked_account.email = request.env["omniauth.auth"].info.email if request.env["omniauth.auth"].info.email

      if request.env["omniauth.auth"].provider == "dwolla"
        token = Payment.dwolla_gateway.request_token(params[:code], user_omniauth_callback_url(:dwolla, port: nil))
        if token.present?
          linked_account.token = token
          linked_account.save
        end
      elsif request.env["omniauth.auth"].provider == "wepay"
        linked_account.token_secret = request.env["omniauth.auth"].credentials.token

        gateway = Payment.wepay_gateway
        response = gateway.call('/account/find', linked_account.token_secret)

        if response.empty?
          response = gateway.call('/account/create', linked_account.token_secret, {
            name: "PayWithMe Account",
            description: "The account for use with PayWithMe events."
          })
          response = gateway.call('/account/find', linked_account.token_secret)
          flash[:notice] = "A new WePay account has been created for you to use with PayWithMe. You need to activate it #{view_context.link_to "here", response.first["verification_uri"]}.".html_safe
        end


        linked_account.token = response.first["account_id"]
        linked_account.save
      elsif request.env["omniauth.auth"].provider == "paypal"
        linked_account.uid = request.env["omniauth.auth"].uid
        linked_account.token = request.env["omniauth.auth"].credentials.token

        linked_account.save
      elsif request.env["omniauth.auth"].provider == "facebook"
        # Set profile image
        if user.profile_image_type == :gravatar
          user.profile_image_type = :url
          user.profile_image_url = request.env["omniauth.auth"].info.image.gsub('?type=square', '?type=large')
        end

      end

      user.save

      if signed_in?
        if current_user.stub?
          # Final stub updates
          current_user.complete_registration!

          # Stub flash message
          flash[:success] = "Account registration successfully completed with #{provider} account!"
        else
          if update
            # Account updated flash message
            flash[:success] = "Synced #{provider} account successfully updated!"
          else
            # Account added flash message
            flash[:success] = "#{provider} account successfully synced!"
          end
          session["user_return_to"] ||= edit_user_registration_path
        end
      else
        if new_registration
          # Registration flash message
          flash[:success] = "Registered with #{provider} successfully."
        else
          # Sign in flash message
          flash[:success] = "Signed in with #{provider} successfully."
        end
      end
      sign_in_and_redirect user
    else
      # Send things over to registration form
      session["devise.user_attributes"] = user.attributes
      session["devise.account_attributes"] = { provider: request.env["omniauth.auth"].provider, uid: request.env["omniauth.auth"].uid }
      redirect_to new_user_registration_path
    end
  end

  def failure
    if signed_in?
      # Convert to error messages that make more sense
      if failed_strategy.name == "dwolla" && failure_message == "Invalid account status for user of this access token."
        failure_message = "Please verify your email address before linking your account."
      end

      flash[:error] = "#{OmniAuth::Utils.camelize(failed_strategy.name)} reported the following error: #{failure_message}"
      redirect_to edit_user_registration_path
    else

    end
    # raise failure_message
    # set_flash_message :alert, :failure, :kind => OmniAuth::Utils.camelize(failed_strategy.name), :reason => failure_message
    # redirect_to after_omniauth_failure_path_for(resource_name)
  end

  alias_method :twitter, :all
  alias_method :facebook, :all
  alias_method :paypal, :all
  alias_method :dwolla, :all
  alias_method :wepay, :all
end