require 'spec_helper'

describe Organization do

	before { @organization = FactoryGirl.create(:organization) }
	subject { @organization }
	it { should be_valid }

	describe "attributes" do
	  [ :comment,
	  	:deal,
	  	:email,
	  	:name,
	  	:organization_name,
	    :split].each do |attribute|
	    it { should respond_to(attribute) }
	  end
	end

	describe "validations" do
		it { should validate_presence_of(:name) }
		it { should validate_presence_of(:email) }
		it { should allow_value("test@test.com").for(:email) }
		it { should allow_value("test+testing@test.com").for(:email) }
		it { should_not allow_value("test.com").for(:email) }
		it { should_not allow_value("test@test").for(:email) }
		it { should_not allow_value("test@.com").for(:email) }
		it { should_not allow_value("@test.com").for(:email) }
		it { should validate_presence_of(:organization_name) }
		it { should ensure_length_of(:comment).is_at_most(250).with_short_message(/has to be less than 250/) }
	end
end