class MyDevise::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :require_no_authentication, only: [:new, :create]
  # before_filter :require_no_authentication_but_allow_stubs, only: [:new, :create]

  helper DeviseHelper

  def new
    if signed_in?
      resource = build_resource({ email: current_user.email })
    else
      resource = build_resource({})
    end

    respond_with resource
  end

  def create
    build_resource

    if signed_in?
      user = current_user
      user.update_attributes!(params[:user])
      user.guest_token = nil
      user.toggle(:stub)
      user.completed_at = Time.now

      if user.save
        flash[:success] = "Account registration successfully completed!"
        sign_in user, bypass: true
        redirect_to after_sign_in_path_for(resource)
      else
        clean_up_passwords resource
        respond_with resource
      end
    else
      if resource.save
        if session["devise.account_attributes"].present?
          resource.linked_accounts.create(session["devise.account_attributes"])
        end
        resource.save

        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_up(resource_name, resource)
          respond_with resource, :location => after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
          respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        respond_with resource
      end
    end
  end

  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end

private
  def require_no_authentication_but_allow_stubs
    if signed_in? && current_user.stub?
      # Let's allow them
    else
      require_no_authentication
    end
  end
end