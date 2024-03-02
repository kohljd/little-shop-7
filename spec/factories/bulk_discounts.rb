FactoryBot.define do
  factory :bulk_discount do
    discount { Faker::Number.within(range: 1..99) }
    quantity { Faker::Number.within(range: 1..15) }
    association :merchant
  end
end