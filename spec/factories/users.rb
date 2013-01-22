# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobarbaz"
    password_confirmation "foobarbaz"
  end

  factory :second_user do
  	name "Second Test User"
  	email "person@example.com"
  	password "foobarbaz"
  	password_confirmation "foobarbaz"
  end

  factory :event do
    sequence(:title) { |n| "Event #{n}" }
    division_type Event::DivisionType::Total
    fee_type Event::FeeType::OrganizerPays
    privacy_type Event::PrivacyType::Public
    due_at { 7.days.from_now }
    start_at { 8.days.from_now }
    total_amount_cents 100
    association :organizer, factory: :user
  end
end