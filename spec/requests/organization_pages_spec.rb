require 'spec_helper'

describe "Organizations page" do
	before do
		@organization = FactoryGirl.create(:organization)
		visit new_organization_path
	end

	subject { page }
	let(:submit) { "Submit" }

	describe "valid submission" do
		before do
			fill_in "Your Name", with: "New Testuser"
			fill_in "Email", with: "example@email.com"
			fill_in "Restaurant Name (optional)", with: "Sample Restaurant"
		end

		it "should add the organization to the database" do
			expect{ click_button submit }.to change(Organization, :count).by(1)
		end
	end

	describe "invalid submission" do

		describe "with no name" do
			before do
				fill_in "Email", with: "example@email.com"
				fill_in "Restaurant Name (optional)", with: "Sample Restaurant"
			end

			it "should not add the organization to the database" do
				expect{ click_button submit }.not_to change(Organization, :count)
			end
		end

		describe "with no email" do
			before do
				fill_in "Your Name", with: "New Testuser"
				fill_in "Restaurant Name (optional)", with: "Sample Restaurant"
			end

			it "should not add the organization to the database" do
				expect{ click_button submit }.not_to change(Organization, :count)
			end
		end

		describe "with invalid email" do
			before do
				fill_in "Your Name", with: "New Testuser"
				fill_in "Email", with: "test@example@email.com"
				fill_in "Restaurant Name (optional)", with: "Sample Restaurant"
			end

			it "should not add the organization to the database" do
				expect{ click_button submit }.not_to change(Organization, :count)
			end
		end

		describe "with comment exceeding 250 characters" do
			before do
				fill_in "Your Name", with: "New Testuser"
				fill_in "Email", with: "example@email.com"
				fill_in "Restaurant Name (optional)", with: "Sample Restaurant"
				fill_in "Comment", with: "a" * 251
			end

			it "should not add the organization to the database" do
				expect{ click_button submit }.not_to change(Organization, :count)
			end
		end
	end
end