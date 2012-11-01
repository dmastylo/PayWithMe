# == Schema Information
#
# Table name: linked_accounts
#
#  id           :integer          not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  provider     :string(255)
#  uid          :string(255)
#  token        :string(255)
#  user_id      :integer
#  token_secret :string(255)
#

require 'spec_helper'

describe LinkedAccount do

  describe "accessible attributes" do
    it "should not allow access to provider" do
      expect do
        LinkedAccount.new(provider: true)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end

    it "should not allow access to uid" do
      expect do
        LinkedAccount.new(uid: true)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end

    it "should not allow access to token" do
      expect do
        LinkedAccount.new(token: true)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end

    it "should not allow access to token_secret" do
      expect do
        LinkedAccount.new(token_secret: true)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

end