class RegistrationsController < Devise::RegistrationsController
  def new
    if session["devise.user_data"]
      resource = build_resource(session["devise.user_data"])
      session["devise.user_data"] = nil
    else
      resource = build_resource
    end

    respond_with resource
  end

  def create
    build_resource
    if resource.provider
      @account = LinkedAccount.new(provider: resource.provider, uid: resource.uid, token: 'test')
      resource.provider = resource.uid = nil
      resource.using_oauth = true
    end

    if resource.save
      resource.linked_accounts << @account if @account
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
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
