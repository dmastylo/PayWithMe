# This probably shouldn't be used much

FactoryGirl.define do
  factory :news_item do
    news_type 1
    foreign_type 1
    foreign_id 1
    association :user
  end
end