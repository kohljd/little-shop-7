require "rails_helper"

RSpec.describe "Merchant's Bulk Discount Show", type: :feature do
  describe "when merchant visits" do
    let!(:merchant_1) {create(:merchant)}
    let!(:bulk_discount_1) {merchant_1.bulk_discounts.create!(discount: 20, quantity: 10)}
    let!(:bulk_discount_2) {merchant_1.bulk_discounts.create!(discount: 10, quantity: 15)}

    before do
      visit merchant_bulk_discount_path(merchant_1, bulk_discount_1)
    end

    it "displays bulk discount's percentage off" do
      expect(page).to have_content("20% off")
      expect(page).to_not have_content("15% off")
    end

    it "displays bulk discount's quantity threshold" do
      expect(page).to have_content("10 items")
      expect(page).to_not have_content("15 items")
    end
  end
end