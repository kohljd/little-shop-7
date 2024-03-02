require "rails_helper"

RSpec.describe "Merchant Bulk Discount New", type: :feature do
  describe "when merchant visits" do
    let!(:merchant_1) {create(:merchant)}

    before do
      new_merchant_bulk_discount_path
    end

    it "displays form title" do
      expect(page).to have_content("New Bulk Discount")
    end

    it "displays empty form" do
      expect(page).to have_field(:discount)
      expect(page).to have_field(:quantity)
    end

    it "redirects completed form to Bulk Discount Index" do
      fill_in "Discount", with: 30
      fill_in "Quantity", with: 25
      click_on "Submit"

      expect(current_path).to eq(merchant_bulk_discounts_path)
      expect(page).to have_content("30% off 25 items")
    end

    it "won't submit incomplete forms" do
      click_on "Submit"

      expect(current_path).to eq(new_merchant_bulk_discount_path)
      expect(page).to have_content("Discount can't be blank")
      expect(page).to have_content("Quantity can't be blank")
    end
  end
end