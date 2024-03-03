require "rails_helper"

RSpec.describe "Merchant Bulk Discount Edit", type: :feature do
  describe "when merchant visits" do
    let!(:merchant_1) {create(:merchant)}
    let!(:bulk_discount_1) {merchant_1.bulk_discounts.create!(discount: 20, quantity: 10)}

    before do
      visit edit_merchant_bulk_discount_path(merchant_1, bulk_discount_1)
    end

    it "displays update form with bulk discount's current info" do
      expect(page).to have_field("Discount", with: 20)
      expect(page).to have_field("Quantity", with: 10)
    end

    it "updated form redirects to Bulk Discount Show" do
      fill_in "Discount", with: 25
      fill_in "Quantity", with: 30
      click_on "Submit"

      expect(current_path).to eq(merchant_bulk_discount_path(merchant_1, bulk_discount_1))
      expect(page).to have_content("Discount: 25% off")
      expect(page).to have_content("Quantity Threshold: 30 items")

      click_on "Update Discount"
      expect(page).to have_field("Discount", with: 25)
      expect(page).to have_field("Quantity", with: 30)

      fill_in "Quantity", with: 22
      click_on "Submit"
      expect(current_path).to eq(merchant_bulk_discount_path(merchant_1, bulk_discount_1))
      save_and_open_page
      expect(page).to have_content("Quantity Threshold: 22 items")
    end

    it "cannot submit form with incomplete field" do
      fill_in "Discount", with: ''
      fill_in "Quantity", with: ''
      click_on "Submit"
      
      expect(current_path).to eq(edit_merchant_bulk_discount_path(merchant_1, bulk_discount_1))
      expect(page).to have_content("Discount can't be blank")
      expect(page).to have_content("Discount is not a number")
      expect(page).to have_content("Quantity can't be blank")
      expect(page).to have_content("Quantity is not a number")
    end
  end
end