require "rails_helper"

RSpec.describe "New Bulk Discount" do
  before do
    @merchant_1 = Merchant.create!(name: "Lance", status: 0)

    @bulk_discount_1 = @merchant_1.bulk_discounts.create!(percentage: "10%", min_amount: 10)
    @bulk_discount_2 = @merchant_1.bulk_discounts.create!(percentage: "25%", min_amount: 15)
  end

  describe "User Story 2" do
    it "has a form to make a new discount" do
      visit new_bulk_discount_path

      expect(page).to have_field("Percentage")
      expect(page).to have_field("Minimum Amount")
      fill_in "Percentage", with: "4%"
      fill_in "Minimum Amount", with: "5"

      expect(page).to have_button("Submit")
      click_on "Submit"

      expect(current_path).to eq(bulk_discounts_path)
      expect(page).to have_content("4%")
      expect(page).to have_content("5")
    end
  end
end