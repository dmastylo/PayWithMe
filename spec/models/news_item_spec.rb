require 'spec_helper'

describe NewsItem do

  before do
    event = FactoryGirl.create(:event)
    event.add_members(FactoryGirl.create_list(:user, 10))
    NewsItem.create_for_new_event_member(event, FactoryGirl.create(:user))
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
        @new_members = FactoryGirl.create_list(:user, 10)
        @event.add_members(@new_members)
      end

      describe "new members" do
        before do
          @new_members.each do |member|
            NewsItem.create_for_new_event_member(@event, member)
          end
          @news_item = @new_members.last.news_items.last
        end
        subject { @news_item }

        it { @news_item.news_type.should eq NewsItem::NewsType::INVITE }
        it { @news_item.foreign_type.should eq NewsItem::ForeignType::EVENT }
        it { @news_item.event.should eq @event }
        it { @news_item.subjects.should eq @new_members - [@new_members.last] }
      end
    end

    describe "for group" do

    end
  end

end