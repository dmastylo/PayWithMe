FactoryGirl.define do
  factory :nudge do
    association :nudgee, factory: :user
    association :nudger, factory: :user
    association :event
  end
end