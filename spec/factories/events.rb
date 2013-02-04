FactoryGirl.define do
  factory :event do
    sequence(:title) { |n| "Event #{n}" }
    division_type Event::DivisionType::TOTAL
    privacy_type Event::PrivacyType::PUBLIC
    due_at { 7.days.from_now }
    total_amount_cents 1000
    association :organizer, factory: :user
  end
end