# == Schema Information
#
# Table name: events
#
#  id                     :integer          not null, primary key
#  title                  :string(255)
#  description            :text
#  due_at                 :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  collection_type        :integer
#  total_cents            :integer
#  per_person_cents       :integer
#  organizer_id           :integer
#  privacy_type           :integer
#  slug                   :string(255)
#  image_file_name        :string(255)
#  image_content_type     :string(255)
#  image_file_size        :integer
#  image_updated_at       :datetime
#  image_url              :string(255)
#  guest_token            :string(255)
#  send_tickets           :boolean          default(FALSE)
#  location_title         :string(255)
#  location_address       :string(255)
#  donation_goal_cents    :integer
#  minimum_donation_cents :integer
#  type                   :string(255)
#

# Untested things that should be tested: (none)

require 'spec_helper'

describe Event do

  before { @event = FactoryGirl.create(:event) }
  subject { @event }
  it { should be_valid }

  describe "dynamic methods" do
    it { should respond_to(:collecting_by_total?) }
    it { should respond_to(:collecting_by_person?) }
    it { should respond_to(:collecting_by_donation?) }
    it { should respond_to(:collecting_by_item?) }
  end

  describe "validations" do
    it { should validate_presence_of(:organizer_id) }
    # it { should validate_presence_of(:collection_type) }
    it { should ensure_length_of(:title).is_at_least(2).is_at_most(120).with_short_message(/has to be between/).with_long_message(/has to be between/) }

    describe "when collecting by total" do
      it { should allow_value("$1234").for(:total) }
      it { should_not allow_value("abcd").for(:total) }
      it { should allow_value("$1234").for(:per_person) }
      it { should allow_value("abcd").for(:per_person) }
    end

    describe "when collecting by person" do
      before { @event.collection_type = Event::Collection::PERSON }
      it { should allow_value("$1234").for(:total) }
      it { should allow_value("abcd").for(:total) }
      it { should allow_value("$1234").for(:per_person) }
      it { should_not allow_value("abcd").for(:per_person) }
    end
  end

  describe "relationships" do
    it { should belong_to(:organizer).class_name("User") }
    it { should have_many(:event_users).dependent(:destroy) }
    it { should have_many(:members).through(:event_users).class_name("User") }
    it { should have_many(:messages).dependent(:destroy) }
    it { should have_many(:event_groups).dependent(:destroy) }
    it { should have_many(:groups).through(:event_groups) }
    it { should have_many(:reminders).dependent(:destroy) }
    it { should have_many(:nudges).dependent(:destroy) }
  end

  describe "mass assignment" do
    [:created_at, :updated_at, :organizer_id].each do |attribute|
      it { should_not allow_mass_assignment_of(attribute) }
    end
  end

end
