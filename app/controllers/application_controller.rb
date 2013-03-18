class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_for_stub_token
  after_filter :user_activity, if: :current_user
  around_filter :user_time_zone, if: :current_user

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

    if @group.members.include?(current_user) || current_user.admin?
      true
    else
      redirect_to_login_or_root
    end
  end

  def user_organizes_group
    @group = current_user.organized_groups.find(params[:group_id] || params[:id])

    if @group.nil? || !@group.is_admin?(current_user)
      redirect_to_login_or_root
    end
  end

  def user_in_event
    @event ||= Event.find(params[:event_id] || params[:id])

    if !signed_in? || (!@event.members.include?(current_user) && !@event.public? && !current_user.admin?)
      redirect_to_login_or_root
    end
  end

  def user_in_event_or_public
    @event = Event.find(params[:event_id] || params[:id])
    (@event.present? && @event.public?) || user_in_event
  end

  def user_organizes_event
    @event = current_user.organized_events.find(params[:event_id] || params[:id])

    if @event.nil?
      redirect_to_login_or_root
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
    if params[:token] && params[:token] != nil
      user = User.find_by_guest_token(params[:token])
      if user.present?
        session[:user_return_to] = url_for(port: false)
        if user.stub?
          sign_in user
          if session[:modal_last_shown].nil? || (Time.now - session[:modal_last_shown]) > 3600
            @display_stub_login = true
            session[:modal_last_shown] = Time.now
          end
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

  def user_activity
    current_user.update_attribute(:last_seen, Time.now)
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def redirect_to_login_or_root
    if !signed_in?
      flash[:error] = "Please login or register to view that page."
      redirect_to new_user_session_path
    else
      flash[:error] = "You're not on the list."
      redirect_to root_path
    end
  end
end