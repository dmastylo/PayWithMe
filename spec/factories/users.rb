# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobarbaz"
    password_confirmation "foobarbaz"

    factory :stub_user do
      password ""
      password_confirmation ""
      stub true
      guest_token "1234567890"
    end

    factory :oauth_user do
      password ""
      password_confirmation ""
      using_oauth true
      after(:create) { |user| user.linked_accounts << FactoryGirl.create(:linked_account, user: user) }
    end
  end
end
