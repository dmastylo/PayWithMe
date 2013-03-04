FactoryGirl.define do
  factory :payment do
    association :payer, factory: :user
    association :payee, factory: :user
    association :event
    requested_at { Time.now }
    due_at { 7.days.from_now }
    payment_method { PaymentMethod.first }
    amount_cents 1000

    after(:build) do |payment|
      payment.event.add_member(payment.payer)
      payment.event_user = payment.event.event_user(payment.payer)
      payment.event_user.event = payment.event
      payment.event_user.user = payment.payer
    end
  end
end