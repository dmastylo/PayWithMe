class RegistrationsController < Devise::RegistrationsController
  def new
    puts session
    if session["devise.user_data"]
      puts "test"
      puts session["devise.user_data"].slice(:name, :username, :email)
      resource = build_resource(session["devise.user_data"].slice(:name, :username, :email))
    else
      resource = build_resource
    end

    respond_with resource
  end

  def create
    build_resource
    if session["devise.user_data"]
      @account = LinkedAccount.new(session["devise.user_data"].slice(:provider, :uid, :token))
      resource.provider = resource.uid = resource.token = nil
      resource.using_oauth = true
    end

    if resource.save
      resource.linked_accounts << @account if @account
      puts @account.inspect
      resource.save
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

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if resource.update_with_password(resource_params)
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      @errors = resource.errors
      render "users/settings"
      # respond_with resource
    end
  end
end
