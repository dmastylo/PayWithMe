class RestaurantContactsController < ApplicationController

	def new
		@restaurant_contact = RestaurantContact.new
	end

	def create
		@restaurant_contact = RestaurantContact.new(params[:restaurant_contact])
		
		if @restaurant_contact.save
			flash[:success] = "Thanks for letting us know. We will contact you soon with more information"
		else
			flash[:error] = "Sorry, some information is missing, please fill in all non-optional fields. Comments can only be a maximum of 140 characters."
		end

		redirect_to restaurants_path
	end
end
