require "rails_helper"

RSpec.describe "Merchant's Bulk Discounts Index", type: :feature do
  describe "when merchant visits" do
    let!(:merchant_1) {create(:merchant)}
    let!(:merchant_2) {create(:merchant)}
    let!(:bulk_discount_1) {merchant_1.bulk_discounts.create!(discount: 20, quantity: 10)}
    let!(:bulk_discount_2) {merchant_1.bulk_discounts.create!(discount: 15, quantity: 15)}
    let!(:bulk_discount_3) {merchant_2.bulk_discounts.create!(discount: 15, quantity: 15)}

    before do
        visit merchant_bulk_discounts_path(merchant_1)
    end

    describe "displays bulk discounts" do
      it "only displays discount's for that merchant" do
        expect(page).to have_css("#bulk_discount-#{bulk_discount_1.id}")
        expect(page).to have_css("#bulk_discount-#{bulk_discount_2.id}")
        expect(page).to_not have_css("#bulk_discount-#{bulk_discount_3.id}")
      end
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

      it "Create new bulk discount" do
        expect(page).to have_link("New Bulk Discount")
        click_on "New Bulk Discount"
        
        expect(current_path).to eq("/merchants/#{merchant_1.id}/bulk_discounts/new")
      end
    end

    describe "displays option to delete bulk discounts" do
      it "delete button next to each discount" do
        within "#bulk_discount-#{bulk_discount_1.id}" do
          expect(page).to have_button("Delete", count: 1)
        end

        within "#bulk_discount-#{bulk_discount_2.id}" do
          expect(page).to have_button("Delete", count: 1)
        end
      end

      it "clicking 'delete' reloads the page without the deleted item" do
        click_on "Delete", match: :first

        expect(current_path).to eq(merchant_bulk_discounts_path(merchant_1))
        expect(page).to_not have_content("20% off 10 items")
        expect(page).to have_no_link("Bulk Discount #{bulk_discount_1.id}", href: merchant_bulk_discount_path(merchant_1, bulk_discount_1))
      end
    end
  end
end