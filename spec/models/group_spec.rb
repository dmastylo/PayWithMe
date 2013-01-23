# == Schema Information
#
# Table name: groups
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  description  :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  slug         :string(255)
#  organizer_id :integer
#

require 'spec_helper'

describe Group do

  before { @group = FactoryGirl.create(:group) }
  subject { @group }
  it { should be_valid }

  describe "attributes" do
    [:title,
     :description,
     :organizer,
     :slug].each do |attribute|
      it { should respond_to(attribute) }
    end
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should ensure_length_of(:name).is_at_least(2).is_at_most(120) }
    it { should validate_presence_of(:organizer_id) }
  end

  describe "associations" do
    it { should have_many(:group_users).dependent(:destroy) }
    it { should have_many(:members).class_name("User").through(:group_users) }
    it { should have_many(:event_groups).dependent(:destroy) }
    it { should have_many(:events).through(:event_groups) }
  end

end
