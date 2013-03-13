require 'spec_helper'

describe "Home and Sign up pages" do
  
	subject{ page }

	describe "Home page" do
		before{ visit root_path }

		it{ should have_selector('title', text: 'PayWithMe')}
		it{ should_not have_selector('title', text: 'PayWithMe |')}

		it "should have proper links on the home page" do

			click_link "Register"
			response.should have_selector('h2', text: 'Register New Account')

			click_link "Login With Facebook"
			response.should have_selector('title', content: 'Facebook')

			click_link "Login With Twitter"
			response.should have_selector('title', content: 'Twitter')

			click_link "Login"
			response.should have_selector('h3', content: 'Welcome!')
		end
	end

	describe "Sign up" do
		before{ visit new_user_registration_path }

		it{ should have_selector('h2', text: 'Register') }

		let(:submit){ "Sign up" }

		describe "with invalid information" do
			
			it "should not create the user due to blank information" do
				expect{ click_button submit }.not_to change(User, :count)
			end

			describe "when the password doesn't match confirmation" do
				before{
					fill_in "Name", 			with: "John Q Sample"
					fill_in "Email", 			with: "test@example.com"
					fill_in "Password", 		with: "foobarbaz"
					fill_in "Confirm Password", with: "mismatch"
				}

				it "should not create the user" do
					expect{ click_button submit }.not_to change(User, :count)
				end
			end
			
			describe "when email" do
				before{
					fill_in "Name", 			with: "John Q Sample"
					fill_in "Email", 			with: ""
					fill_in "Password", 		with: "foobarbaz"
					fill_in "Confirm Password", with: "foobarbaz"
				}

				describe "is blank" do
					
					it "should not create the user" do
						expect{ click_button submit }.not_to change(User, :count)
					end
				end

				describe "has no @" do
					before{ fill_in "Email", with: "testexample.com" }
					
					it "should not create the user" do
						expect{ click_button submit }.not_to change(User, :count)
					end
				end

				describe "has multiple @" do
					before{ fill_in "Email", with: "test@test@example.com" }

					it "should not create the user" do
						expect{ click_button submit }.not_to change(User, :count)
					end	
				end

				describe "has no domain" do
					before{ fill_in "Email", with: "test@examplecom" }

					it "should not create the user" do
						expect{ click_button submit }.not_to change(User, :count)
					end	
				end
			end

			describe "when it doesn't meet minimum password length" do
				before{ 
					fill_in "Name", 			with: "John Q Sample"
					fill_in "Email", 			with: "test@example.com"
					fill_in "Password", 		with: "x" * 7
					fill_in "Confirm Password", with: "x" * 7
				}

				it "should not create the user" do
					expect{ click_button submit }.not_to change(User, :count)
				end
			end
		end

		describe "with valid information" do
			before{
				fill_in "Name", 			with: "John Q Sample"
				fill_in "Email", 			with: "test@example.com"
				fill_in "Password", 		with: "foobarbaz"
				fill_in "Confirm Password", with: "foobarbaz"				
			}

			it "should create the user" do
				expect{ click_button submit }.to change(User, :count).by(1)
			end
		end
	end
end
