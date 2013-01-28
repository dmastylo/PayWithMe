# == Schema Information
#
# Table name: groups
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  description        :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  slug               :string(255)
#  organizer_id       :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  image_url          :string(255)
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
    it { should validate_presence_of(:title) }
    it { should ensure_length_of(:title).is_at_least(2).is_at_most(120).with_short_message(/has to be between/).with_long_message(/has to be between/) }
    it { should validate_presence_of(:organizer_id) }
  end

  describe "associations" do
    it { should have_many(:group_users).dependent(:destroy) }
    it { should have_many(:members).class_name("User").through(:group_users) }
    it { should have_many(:event_groups).dependent(:destroy) }
    it { should have_many(:events).through(:event_groups) }
  end

  describe "members" do
    describe "adding" do
      describe "multiple" do
        before do
          @members = FactoryGirl.create_list(:user, 10)
          @group.add_members(@members)
        end
        it "should include all members" do
          @members.each do |member|
            @group.members.should include(member)
          end
        end
      end

      describe "single" do
        before do
          @member = FactoryGirl.create(:user)
          @group.add_member(@member)
        end
        it { @group.members.should include(@member) }
      end
    end

    describe "setting" do
      before do
        @original_members = FactoryGirl.create_list(:user, 10)
        @group.add_members(@original_members)
        @new_members = FactoryGirl.create_list(:user, 10)
        @group.set_members(@new_members)
      end

      it { @group.members.should eq @new_members }
      it "should not include uninvited members" do
        @original_members.each do |member|
          @group.members.should_not include(member)
        end
      end
    end

    describe "removing" do
      describe "multiple" do
        before do
          @uninvited_members = FactoryGirl.create_list(:user, 3)
          @new_members = FactoryGirl.create_list(:user, 3)
          @group.add_members(@uninvited_members + @new_members)
          @group.remove_members(@uninvited_members)
        end

        it "should not include uninvited members" do
          @uninvited_members.each do |member|
            @group.members.should_not include(member)
          end
        end

        it "should include other members" do
          @new_members.each do |member|
            @group.members.should include(member)
          end
        end
      end

      describe "single" do
        before do
          @uninvited_member = FactoryGirl.create(:user)
          @new_members = FactoryGirl.create_list(:user, 3)
          @group.add_members([@uninvited_member] + @new_members)
          @group.remove_member(@uninvited_member)
        end

        it "should not include uninvited member" do
          @group.members.should_not include(@uninvited_member)
        end

        it "should include other members" do
          @new_members.each do |member|
            @group.members.should include(member)
          end
        end
      end
    end
  end

end
