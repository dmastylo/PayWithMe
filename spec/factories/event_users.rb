FactoryGirl.define do
  factory :event_user do
    association :member, factory: :user
    association :event
  end
end