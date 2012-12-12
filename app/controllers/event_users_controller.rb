class EventUsersController < ApplicationController
    before_filter :user_is_organizer

    def create
        # for some reason member_ids.include? does not work
        unless @event.members.include?(User.find(params[:event_user][:user_id]))
            @event_user = EventUser.create(params[:event_user])
            if @event_user.save
                @event.set_event_user_attributes(current_user)

                respond_to do |format|
                    format.html { redirect_to user_path(@user) }
                    format.js
                end
            else
                flash[:error] = "Adding user failed!"
                redirect_to user_path(@user)
            end
        end
    end

    private
        def user_is_organizer
            @event = current_user.organized_events.find_by_id(params[:event_user][:event_id])

            if @event.nil?
              flash[:error] = "You're not the organizer of this event."
              redirect_to root_path
            end
        end
end
