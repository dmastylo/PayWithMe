class OrganizationsController < ApplicationController
	def new
		@organization = Organization.new
	end

	def create
		@organization = Organization.new(params[:organization])

		if @organization.save
			flash[:success] = "Thanks for letting us know. We will contact you soon with more information."

			redirect_to root_path
		else
			render "new"
		end
	end
end