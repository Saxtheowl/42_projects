FactoryBot.define do
  factory :order do
    association :user
    total { 99.99 }
    status { 'pending' }
  end
end
