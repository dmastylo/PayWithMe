require 'spec_helper'

describe "Account Settings" do
	
	before do
		@user = FactoryGirl.create(:user)
		visit user_path
	end

	subject{ page }

	describe "when profile picture" do

	#is changed to gravatar

	#is changed to url

	#is changed to file
	end

	describe "when name" do
		describe "is changed" do

		end

		#is blank

		#exceeds maximum
	end

	describe "when email" do
		describe "is changed" do
			before do
				fill_in "email", with: "new_email@example.com"
				click_button "Update Info"
			end

			it "should successfully save changes" do
				response.should have_selector('p', text: "Successfully Saved")
			end
		end

		#is blank

		#is no longer valid
	end
end