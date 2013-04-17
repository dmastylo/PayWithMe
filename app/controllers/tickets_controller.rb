class TicketsController < ApplicationController

	def show

		event_user_id = params[:event_user_id]

		if(event_user_id.to_i < EventUser.count)
			@event_user = EventUser.find_by_id(event_user_id)
			if(@event_user.event.organizer == current_user || @event_user.user == current_user)
				render 'show'
			else
				flash[:error] = "You do not have permission to view that page. Only the event organizer and the payer can view the page. Please sign in if you are the organizer or payer."
				redirect_to root_path
			end
		else
			render 'errors/does_not_exist'
		end
	end
end
