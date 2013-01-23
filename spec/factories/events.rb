FactoryGirl.define do
  factory :event do
    sequence(:title) { |n| "Event #{n}" }
    division_type Event::DivisionType::Total
    fee_type Event::FeeType::OrganizerPays
    privacy_type Event::PrivacyType::Public
    due_at { 7.days.from_now }
    start_at { 8.days.from_now }
    total_amount_cents 1000
    association :organizer, factory: :user
  end
end