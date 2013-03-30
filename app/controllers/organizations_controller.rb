class OrganizationsController < ApplicationController
	def new
		@organization = Organization.new
	end

	def create
		@organization = Organization.new(params[:organization])

		if @organization.save
			flash[:success] = "Thanks for letting us know. We will contact you soon with more information."
		else
			flash[:error] = "Sorry, some information is missing, please fill in all non-optional fields. Comments can only be a maximum of 250 characters."
		end

		redirect_to organizations_path
	end
end