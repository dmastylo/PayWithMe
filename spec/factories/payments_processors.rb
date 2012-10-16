# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payments_processor, :class => 'PaymentsProcessors' do
    processor_id 1
    payment_id 1
  end
end
