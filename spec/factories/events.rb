FactoryGirl.define do
  factory :event do
    sequence(:title) { |n| "Event #{n}" }
    collection_type Event::Collection::TOTAL
    privacy_type Event::Privacy::PUBLIC
    due_at { 7.days.from_now }
    total 10.00
    association :organizer, factory: :user
  end

  factory :invalid_event, parent: :event do
    title ""
  end
end