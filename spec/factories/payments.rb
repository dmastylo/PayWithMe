FactoryGirl.define do
  factory :payment do
    association :payer, factory: :user
    association :payee, factory: :user
    association :event
    association :event_user
    requested_at { Time.now }
    due_at { 7.days.from_now }
    amount_cents 1000

    after(:build) do |payment|
      payment.event_user.event = payment.event
      payment.event_user.user = payment.payer
    end
  end
end