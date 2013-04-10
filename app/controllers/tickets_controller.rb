class TicketsController < ApplicationController

	def show
		@event_user = EventUser.find_by_id(params[:eu_id])
		puts @event_user.user.name
	end
end
