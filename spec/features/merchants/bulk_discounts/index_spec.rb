require "rails_helper"

RSpec.describe "Merchant's Bulk Discounts Index", type: :feature do
  describe "when merchant visits" do
    let!(:merchant_1) {create(:merchant)}
    let!(:bulk_discount_1) {merchant_1.bulk_discounts.create!(discount: 20, quantity: 10)}
    let!(:bulk_discount_2) {merchant_1.bulk_discounts.create!(discount: 15, quantity: 15)}

    before do
        visit merchant_bulk_discounts_path(merchant_1)
    end

    describe "displays bulk discounts w/their attributes" do
      it "percentage discounts" do
        within "#bulk_discount-#{bulk_discount_1.id}" do
          expect(page).to have_content("20% off")
          expect(page).to_not have_content("15% off")
        end

        within "#bulk_discount-#{bulk_discount_2.id}" do
          expect(page).to have_content("15% off")
          expect(page).to_not have_content("20% off")
        end
      end

      it "required item quantity" do
        within "#bulk_discount-#{bulk_discount_1.id}" do
          expect(page).to have_content("10 items")
          expect(page).to_not have_content("15 items")
        end

        within "#bulk_discount-#{bulk_discount_2.id}" do
          expect(page).to have_content("15 items")
          expect(page).to_not have_content("10 items")
        end
      end
    end

    describe "displays links to" do
      it "Merchant Bulk Discount's Show" do
        within "#bulk_discount-#{bulk_discount_1.id}" do
          expect(page).to have_link("Bulk Discount #{bulk_discount_1.id}")
          click_on "Bulk Discount #{bulk_discount_1.id}"
          expect(current_path).to eq(merchant_bulk_discount_path(merchant_1, bulk_discount_1))
        end

        visit merchant_bulk_discounts_path(merchant_1)

        within "#bulk_discount-#{bulk_discount_2.id}" do
          expect(page).to have_link("Bulk Discount #{bulk_discount_2.id}")
          click_on "Bulk Discount #{bulk_discount_2.id}"
          expect(current_path).to eq(merchant_bulk_discount_path(merchant_1, bulk_discount_2))
        end
      end
    end
  end
end