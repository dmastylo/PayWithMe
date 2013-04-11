# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  split      :boolean          default(TRUE)
#  deal       :boolean          default(TRUE)
#  comment    :string(255)
#  name       :string(255)
#  contact    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  type       :string(255)
#

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
