#require 'rails_helper'

FactoryBot.define do
  factory :invoice_item do
    quantity { Faker::Name.quanity }
    unit_price { Faker::Number.between(from: 100, to: 100000) }
    status { 0 }
    association :item
    association :invoice
  end
end