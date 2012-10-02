class RegistrationsController < Devise::RegistrationsController
  def new
    if session["devise.user_data"]
      resource = build_resource(session["devise.user_data"])
      session["devise.user_data"] = nil
    else
      resource = build_resource({})
    end

    respond_with resource
  end
end
