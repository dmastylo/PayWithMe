require 'spec_helper'

describe "Sign in page" do
	
	before do
		@user = FactoryGirl.create(:user)
		visit new_user_session_path 
	end

	subject { page }

	describe "valid sign in" do
		before do
			fill_in "Email", with: @user.email
			fill_in "Password", with: "foobarbaz"
			click_button "Sign in"
		end

		it "should allow the user to sign in and lead to their page" do
			response.should redirect_to user_path(@user)
		end
	end

	describe "invalid sign in" do

		describe "with non-existent email" do
			before do
				fill_in "Email", with: "thisemaildoesnotexist@neverhasexisted.org"
				fill_in "Password", with: "foobarbaz"
				click_button "Sign in"
			end

			it "should not sign the user in" do
				response.should have_selector('p', text: "Invalid")
			end
		end

		describe "with incorrect password" do
			before do
				fill_in "Email", with: @user.email
				fill_in "Password", with: "loremipsumquux"
				click_button "Sign in"
			end

			it "should not sign the user in" do
				response.should_not redirect_to user_path(@user)
			end
		end
	end


end