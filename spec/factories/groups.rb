FactoryGirl.define do
  factory :group do
    sequence(:title) { |n| "Group #{n}" }
    association :organizer, factory: :user
  end
end