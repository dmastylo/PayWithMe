class GuestChecklistsController < ApplicationController

	def new
		@guest_checklist = GuestChecklist.new
	end
end
