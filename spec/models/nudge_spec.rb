# == Schema Information
#
# Table name: nudges
#
#  id         :integer          not null, primary key
#  nudgee_id  :integer
#  nudger_id  :integer
#  event_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Nudge do

  before { @nudge = FactoryGirl.create(:nudge) }
  subject { @nudge }
  it { should be_valid }

  describe "attributes" do
    [:nudgee_id,
     :nudger_id,
     :event_id].each do |attribute|
      it { should respond_to(attribute) }
    end
  end

  describe "validations" do
    [:nudgee_id,
     :nudger_id,
     :event_id].each do |attribute|
      it { should validate_presence_of(attribute) }
    end
  end

  describe "associations" do
    it { should belong_to(:nudgee).class_name("User") }
    it { should belong_to(:nudger).class_name("User") }
    it { should belong_to(:event) }
  end

end
