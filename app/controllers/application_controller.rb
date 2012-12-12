class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_for_stub_token

  def default_url_options
    if Rails.env.production?
      {host: "paywith.me"}.merge(super)
    else
      {host: "localhost:3000"}.merge(super)
    end
  end

protected
  def user_in_group
    @group = Group.find(params[:group_id] || params[:id])

    if @group.members.include?(current_user)
      true
    else
      flash[:error] = "You're not on the list."
      redirect_to root_path
    end
  end

  def user_organizes_group
    @group = current_user.groups.find_by_id(params[:group_id] || params[:id])

    if @group.nil? || !@group.is_admin?(current_user)
      flash[:error] = "You're not on the list."
      redirect_to root_path
    end
  end

  def user_in_event
    @event = current_user.member_events.find_by_id(params[:event_id] || params[:id])

    if @event.nil?
      flash[:error] = "You're not on the list."
      redirect_to root_path
    end
  end

  def user_organizes_event
    @event = current_user.organized_events.find_by_id(params[:event_id] || params[:id])

    if @event.nil?
      flash[:error] = "You're not on the list."
      redirect_to root_path
    end
  end

  def user_not_stub
    if current_user.stub?
      flash[:error] = "A full account is required in order to make an event."
      session[:user_return_to] = url_for(port: false)
      redirect_to new_user_registration_path(guest: true)
    end
  end

private
  def check_for_stub_token
    if params[:token]
      user = User.find_by_guest_token(params[:token])
      if user.present?
        session[:user_return_to] = url_for(port: false)
        if user.stub?
          sign_in user
          @display_stub_login = true
          @stub_user = User.new(email: user.email)
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