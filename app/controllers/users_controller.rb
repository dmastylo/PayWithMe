class UsersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = User.find(params[:id])
    if request.path != user_path(@user)
      redirect_to user_path(@user), status: :moved_permanently
    end

    @your_organized_and_public_events = current_user.upcoming_organized_events.where(privacy_type: Event::PrivacyType::PRIVATE) + current_user.upcoming_events.where(privacy_type: Event::PrivacyType::PUBLIC)

    if @user == current_user
      @upcoming_public_and_shared_events = current_user.upcoming_events
      @past_public_and_shared_events = current_user.past_events

      # Combined for counts
      @combined_member_events = @upcoming_public_and_shared_events | @past_public_and_shared_events
      @combined_organized_events = @combined_member_events.delete_if { |event| event.organizer != @user }
    else
      # Upcoming Events
      upcoming_public_events = @user.upcoming_events.where(privacy_type: Event::PrivacyType::PUBLIC)
      upcoming_shared_events = @user.upcoming_events.merge current_user.upcoming_events.select { |your_member_event| @user.upcoming_events.include? your_member_event }
      @upcoming_public_and_shared_events = upcoming_public_events | upcoming_shared_events

      # Past Events
      past_public_events = @user.past_events.where(privacy_type: Event::PrivacyType::PUBLIC)
      past_shared_events = @user.past_events.merge current_user.past_events.select { |your_member_event| @user.past_events.include? your_member_event }
      @past_public_and_shared_events = past_public_events | past_shared_events

      # Combined for counts
      @combined_member_events = @upcoming_public_and_shared_events | @past_public_and_shared_events
      @combined_organized_events = @combined_member_events.delete_if { |event| event.organizer != @user }
    end

    @event_user = EventUser.new
  end

  def search
    @query = params[:name]
    if @query.nil? || @query.empty?
      flash.now[:error] = "Please enter a search term."
    else
      @users = User.search_by_name_and_email(@query, current_user)
      @users = @users.reject { |result| result == current_user }
    end
    @users ||= []

    respond_to do |format|
      format.html
      format.json do
        @users.collect! { |user| view_context.user_for_mustache(user) }
        render json: @users
      end
    end
  end
end