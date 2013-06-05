# == Schema Information
#
# Table name: linked_accounts
#
#  id           :integer          not null, primary key
#  provider     :string(255)
#  token        :string(255)
#  user_id      :integer
#  uid          :string(255)
#  token_secret :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  email        :string(255)
#

require 'spec_helper'

describe LinkedAccount do

  before { @linked_account = FactoryGirl.create(:linked_account) }
  subject { @linked_account }
  it { should be_valid }

  describe "attributes" do
    [:provider,
     :token,
     :user_id,
     :uid,
     :token_secret,
     :email].each do |attribute|
      it { should respond_to(attribute) }
    end
  end

  describe "validations" do
    it { should validate_presence_of(:provider) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:uid) }
  end

  describe "associations" do
    it { should belong_to(:user) }
  end

end
