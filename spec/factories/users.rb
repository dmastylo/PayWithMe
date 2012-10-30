# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    sequence(:username)  { |n| "person#{n}" }
    password "foobar"
    password_confirmation "foobar"
  end
end