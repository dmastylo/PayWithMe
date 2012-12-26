class EventUsersController < ApplicationController
    before_filter :user_organizes_event

    def create
        # for some reason member_ids.include? does not work
        unless @event.members.include?(User.find(params[:event_user][:user_id]))
            @event_user = EventUser.create(params[:event_user])
            NewsItem.create_for_new_event_member(@event, @event_user.member)
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
end
