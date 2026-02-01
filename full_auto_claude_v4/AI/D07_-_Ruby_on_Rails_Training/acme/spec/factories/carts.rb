FactoryBot.define do
  factory :cart do
    sequence(:session_id) { |n| "session_#{n}" }
  end
end
