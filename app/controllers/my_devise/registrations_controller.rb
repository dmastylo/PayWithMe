class MyDevise::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :require_no_authentication, only: [:new, :create]
  before_filter :require_no_authentication_but_allow_stubs, only: [:new, :create]

  def new
    if signed_in?
      resource = build_resource({ email: current_user.email })
    else
      resource = build_resource({})
    end

    respond_with resource
  end

  def create
    if signed_in?
      build_resource
      user = current_user
      user.update_attributes!(params[:user])
      user.guest_token = nil
      user.toggle(:stub)

      if user.save
        flash.now[:success] = "Account successfully updated!"
        sign_in user, bypass: true
        redirect_to after_sign_in_path_for(resource)
      else
        clean_up_passwords resource
        respond_with resource
      end
    else
      super
    end
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