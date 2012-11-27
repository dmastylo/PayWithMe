require 'spec_helper'

describe "PageContents" do
  
	subject{ page }

	describe "Home page" do
		before{ visit root_path }

		it{ should have_selector('title', text: 'PayWithMe')}
		it{ should_not have_selector('title', text: 'PayWithMe |')}

		it "should have proper links on the home page" do

			before{ click_link "Register" }

			click_link "Register"
			response.should have_selector('title', text: 'PayWithMe | Register')
			response.should have_selector('h1', content: 'Register')

			click_link "Login With Facebook"
			response.should have_selector('title', content: 'Facebook')

			click_link "Login With Twitter"
			response.should have_selector('title', content: 'Twitter')

			click_link "Login"
			response.should have_selector('h3', content: 'Welcome!')
		end
	end

	describe "Sign up" do
		before{ visit signup_path }

		it{ should have_selector('h1', text: 'Sign Up') }

		let(:submit){ "Create Account" }

		describe "with invalid information" do
			it "should not create the user due to blank information" do
				expect{ click_button submit }.not_to change(User, :count)
			end

			it "should not create the user due to mismatching password" do
				
				before do
					fill_in "Name" 				with "John Q Sample"
					fill_in "Username"			with "sampleuser"
					fill_in "Email" 			with "test@example.com"
					fill_in "Password" 			with "foobarbaz"
					fill_in "Confirm Password" 	with "mismatch"
				end

				expect{ click_button submit }.not_to change(User, :count)
			end
			
			it "should not create the user due to no email" do
				
				before do
					fill_in "Name" 				with "John Q Sample"
					fill_in "Username"			with "sampleuser"
					fill_in "Email" 			with ""
					fill_in "Password" 			with "foobarbaz"
					fill_in "Confirm Password" 	with "mismatch"
				end

				expect{ click_button submit }.not_to change(User, :count)
			end

			it "should "
		end

		describe "with valid information" do
			before do
				fill_in "Name" 				with "John Q Sample"
				fill_in "Username"			with "sampleuser"
				fill_in "Email" 			with "test@example.com"
				fill_in "Password" 			with "foobarbaz"
				fill_in "Confirm Password" 	with "foobarbaz"
			end

			it "should create the user" do
				expect{ click_button submit }.to change(User, :count).by(1)
			end
		end
	end
end
