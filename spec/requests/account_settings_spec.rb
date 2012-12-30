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
				@user.name.should == "New Name"
			end
		end

		describe "is changed to be blank" do
			before do
				fill_in "user_name", with: ""
				click_button submit
			end

			it "should reject changes" do
				@user.name.should_not == ""
			end
		end

		describe "is changed to exceed maximum" do
			before do
				fill_in "user_name", with: 'x'*60
				click_button submit
			end

			it "should reject changes" do
				@user.name.should_not == 'x'*60
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
				@user.email.should == "new_email@example.com"
			end
		end

		describe "is blank" do
			before do
				fill_in "user_email", with: ""
				click_button "Update Info"
			end

			it "should not save changes" do
				@user.email.should_not == ""
			end
		end

		describe "is not valid because it" do
			describe "has no @" do
				before do
					fill_in "user_email", with: "test_at_example.com"
				end

				it "should not save changes" do
					@user.email.should == "test_at_example.com"
				end
			end

			describe "has no domain" do
				before do
					fill_in "user_email", with: "test@exmaple_dot_com"
				end

				it "should not save changes" do
					@user.email.should == "test@example_dot_com"
				end
			end

			describe "belongs to another user" do
				before do
					@secondUser = FactoryGirl.create(:second_user)
					fill_in "user_email", with: "person@example.com"
				end

				it "should not save changes" do
					@user.email.should == "person@example.com"
				end
			end
		end
	end
end