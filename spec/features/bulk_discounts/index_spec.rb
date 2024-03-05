require "rails_helper"

RSpec.describe "Bulk discount index" do
  before do
    @merchant_1 = Merchant.create!(name: "Lance", status: 0)

    @bulk_discount_1 = @merchant_1.bulk_discounts.create!(percentage: "10%", min_amount: 10)
    @bulk_discount_2 = @merchant_1.bulk_discounts.create!(percentage: "25%", min_amount: 15)
  end

  it "see all of my bulk discounts including their attributes" do
    visit bulk_discounts_path
    
    expect(page).to have_content(@bulk_discount_1.percentage)
    expect(page).to have_content(@bulk_discount_2.percentage)
    
    expect(page).to have_content(@bulk_discount_1.min_amount)
    expect(page).to have_content(@bulk_discount_2.min_amount)
  end

  it "links to bulk discounts show page" do
    visit bulk_discounts_path

    expect(page).to have_link("Percentage Discount")
    expect(page).to have_link("Quantity Threshold")
  end
end