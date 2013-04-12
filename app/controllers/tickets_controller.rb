class TicketsController < ApplicationController

	def show
		@event_user = EventUser.find_by_id(params[:event_user_id])
	end
end
