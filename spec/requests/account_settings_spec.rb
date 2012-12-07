require 'spec_helper'

describe "Account Settings" do
	
	before do
		
		# Create a new user
		@user = FactoryGirl.create(:user)
		
		# Login with that user
		visit new_user_session_path
		fill_in "Email", with: @user.email
		fill_in "Password", with: "foobarbaz"
		click_button "Sign in"

		# Try to edit user information
		visit edit_user_registration_path
	end

	subject{ page }

	let(:submit){ "Update Info" }

	describe "when profile picture" do

	#is changed to gravatar

	#is changed to url

	#is changed to file
	end

	describe "when name" do
		describe "is changed to something valid" do
			before do
				fill_in "user_name", with: "New Name"
				click_button submit
			end

			it "should successfully save changes" do
				response.should have_selector('div.alert', text: "Successfully Saved") #Needs to be fixed
			end
		end

		describe "is changed to be blank" do
			before do
				fill_in "user_name", with: ""
				click_button submit
			end

			it "should reject changes" do
				response.should have_selector('div.alert-error') #Needs to be fixed
			end
		end

		describe "is changed to exceed maximum" do
			before do
				fill_in "user_name", with: 'x'*60
				click_button submit
			end

			it "should reject changes" do
				response.should have_selector('div.alert-error') #Needs to be fixed
			end
		end
	end

	describe "when email" do
		describe "is changed" do
			before do
				fill_in "user_email", with: "new_email@example.com"
				click_button "Update Info"
			end

			it "should successfully save changes" do
				response.should have_selector('div.alert', text: "Successfully Saved") #Needs to be fixed
			end
		end

		#is blank

		#is no longer valid
	end
end