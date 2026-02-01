FactoryBot.define do
  factory :in_mail do
    sender { nil }
    recipient { nil }
    subject { "MyString" }
    body { "MyText" }
    read { false }
  end
end
