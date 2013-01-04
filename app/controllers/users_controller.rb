class UsersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = User.find(params[:id])
    @your_organized_events = current_user.organized_events

    if @user == current_user
        @public_and_shared_events = current_user.member_events
    else
        public_events = @user.member_events.where(privacy_type: Event::PrivacyType::Public)
        shared_events = @user.member_events.merge current_user.member_events.select { |your_member_event| @user.member_events.include? your_member_event }
        @public_and_shared_events = public_events | shared_events
    end

    @event_user = EventUser.new
  end

  def search
    @query = params[:name]
    if @query.nil? || @query.empty?
      flash.now[:error] = "Please enter a search term."
    else
      @users = User.search_by_name_and_email(@query)
      @users = @users.reject { |result| result == current_user }
    end
    @users ||= []

    respond_to do |format|
      format.html
      format.json do
        @users = @users.collect { |result| {id: result.id, name: result.name || result.email, profile_image: view_context.profile_image_tag(result), email: result.email } }
        render json: @users
      end
    end
  end
end