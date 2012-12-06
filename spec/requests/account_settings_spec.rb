require 'spec_helper'

describe "Account Settings" do
	
	before do
		@user = FactoryGirl.create(:user)
		visit user_path
	end

	describe "when profile picture" do

	end

	describe "when name" do

	end

	describe "when email" do
		describe "is changed" do
			before do
				fill_in "email", with: "new_email@example.com"
				click_button "Update All"
			end

			it "should successfully save changes" do
				#check for success dialog
			end
		end
	end
end