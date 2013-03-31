class OrganizationsController < ApplicationController
	def new
		@organization = Organization.new
	end

	def create
		@organization = Organization.new(params[:organization])

		if @organization.save
			flash[:success] = "Thanks for letting us know. We will contact you soon with more information."
		else
			render "new"
		end
	end
end