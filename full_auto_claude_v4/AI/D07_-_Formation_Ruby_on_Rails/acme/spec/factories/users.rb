FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }

    trait :admin do
      after(:create) { |user| user.add_role(:admin) }
    end

    trait :mod do
      after(:create) { |user| user.add_role(:mod) }
    end
  end
end
