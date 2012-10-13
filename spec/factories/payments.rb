# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment do
    payee_id 1
    payer_id 1
    amount 1.5
    paid_at "2012-10-13 16:40:26"
    desired_at "2012-10-13 16:40:26"
  end
end
