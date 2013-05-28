# == Schema Information
#
# Table name: news_items
#
#  id           :integer          not null, primary key
#  news_type    :integer
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  foreign_id   :integer
#  foreign_type :integer
#  read         :boolean          default(FALSE)
#

require 'spec_helper'

describe NewsItem do

  before do
    event = FactoryGirl.create(:event)
    event.add_members(FactoryGirl.create_list(:user, 10))
    NewsItem.create_for_new_event_member(event.id, [FactoryGirl.create(:user).id])
    @news_item = NewsItem.last
  end
  subject { @news_item }
  it { should be_valid }

  describe "attributes" do
    [:title,
     :body,
     :subjects,
     :foreign_id,
     :event,
     :group].each do |attribute|
      it { should respond_to(attribute) }
    end
  end

  describe "validations" do
    it { should validate_presence_of(:news_type) }
    it { should validate_presence_of(:foreign_type) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:foreign_id) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_and_belong_to_many(:subjects).class_name("User") }
  end

  describe "creation" do
    describe "for event" do
      before do
        @event = FactoryGirl.create(:event)
        @organizer = @event.organizer
        @members = FactoryGirl.create_list(:user, 10)
        @event.add_members(@members)
      end

      describe "new members" do
        before do
          @members.each do |member|
            NewsItem.create_for_new_event_member(@event.id, [member.id])
          end
          @news_item = @members.last.news_items.last
        end
        subject { @news_item }

        it { @news_item.news_type.should eq NewsItem::NewsType::INVITE }
        it { @news_item.foreign_type.should eq NewsItem::ForeignType::EVENT }
        it { @news_item.event.should eq @event }
        it { @news_item.subjects.should eq @members - [@members.last] }
      end

      describe "new messages" do
        before do
          @members.each do |member|
            message = FactoryGirl.create(:message, user: member, event: @event)
            NewsItem.create_for_new_messages(@event.id, member.id)
          end
          @news_item = @members.last.news_items.last
        end
        subject { @news_item }

        it { @news_item.news_type.should eq NewsItem::NewsType::MESSAGE }
        it { @news_item.foreign_type.should eq NewsItem::ForeignType::EVENT }
        it { @news_item.event.should eq @event }
        it { @news_item.subjects.should eq @members - [@members.last] }
      end
    end

    describe "for group" do
      before do
        @group = FactoryGirl.create(:group)
        @organizer = @group.organizer
        @members = FactoryGirl.create_list(:user, 10)
        @group.add_members(@members)
      end

      describe "new members" do
        before do
          @members.each do |member|
            NewsItem.create_for_new_group_member(@group.id, [member.id])
          end
          @news_item = @members.last.news_items.last
        end
        subject { @news_item }

        it { @news_item.news_type.should eq NewsItem::NewsType::INVITE }
        it { @news_item.foreign_type.should eq NewsItem::ForeignType::GROUP }
        it { @news_item.group.should eq @group }
        it { @news_item.subjects.should eq @members - [@members.last] }
      end
    end
  end

end
