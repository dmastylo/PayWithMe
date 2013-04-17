class TicketsController < ApplicationController

	def show

		event_user_id = params[:event_user_id]

		if(event_user_id.to_i < EventUser.count)
			@event_user = EventUser.find_by_id(params[:event_user_id])
		else
			render 'errors/does_not_exist'
		end
	end
end
