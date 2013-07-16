FactoryGirl.define do
  factory :payment do
    association :payer, factory: :user
    association :event
  end
end