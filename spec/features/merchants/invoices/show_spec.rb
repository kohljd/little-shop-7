require 'rails_helper'

RSpec.describe 'Merchant Invoices Show Page', type: :feature do
  describe 'As a Merchant ' do
    describe "tests I'm not touching" do
      before(:each) do
        @yain = Customer.create!(first_name: "Yain", last_name: "Porter")
        @abdul = Customer.create!(first_name: "Abdul", last_name: "R")

        @merchant_1 = Merchant.create!(name: "Barry")
        @item_1 = create(:item, name: "book", merchant: @merchant_1)
        @item_2 = create(:item, name: "belt", merchant: @merchant_1)

        @invoice_1 = Invoice.create!(customer_id: @yain.id, status: 1, created_at: "2011-09-13")

        @invoice_item_1 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_1.id, quantity: 1, unit_price: 2500, status: 0) # pending
        @invoice_item_2 = InvoiceItem.create!(item_id: @item_2.id, invoice_id: @invoice_1.id, quantity: 2, unit_price: 1000, status: 1) # packaged
        @invoice_item_3 = InvoiceItem.create!(item_id: @item_2.id, invoice_id: @invoice_1.id, quantity: 6, unit_price: 1000, status: 1) # packaged

        @merchant_2 = Merchant.create!(name: "Jane")
        @item_3 = create(:item, name: "soda", merchant: @merchant_2)
        @item_4 = create(:item, name: "shoe", merchant: @merchant_2)

        @invoice_2 = Invoice.create!(customer_id: @abdul.id, status: 0, created_at: "2011-09-14")

        @invoice_item_4 = InvoiceItem.create!(item_id: @item_3.id, invoice_id: @invoice_2.id, quantity: 2, unit_price: 1000, status: 1) # packaged

        visit merchant_invoice_path(@merchant_1, @invoice_1)
      end

      describe "User Story 15 - Listing Invoice Attributes" do
        it "displays all the information related to the Invoice" do
          expect(page).to have_content("Invoice ##{@invoice_1.id}")
          expect(page).to have_content("Status: Completed")
          expect(page).to have_content("Created on: Tuesday, September 13, 2011")
          expect(page).to have_content("Customer: Yain Porter")

          visit merchant_invoice_path(@merchant_2, @invoice_2)

          expect(page).to have_content("Invoice ##{@invoice_2.id}")
          expect(page).to have_content("Status: In Progress")
          expect(page).to have_content("Created on: Wednesday, September 14, 2011")
          expect(page).to have_content("Customer: Abdul R")
        end
      end

      describe "User Story 16 - Invoice Item Information" do
        it "lists all items on the invoice" do
          expect(page).to have_content("Item Name")
          expect(page).to have_content("Quantity")
          expect(page).to have_content("Unit Price")
          expect(page).to have_content("Status")

          within "#invoice_item-#{@invoice_item_1.id}" do
            expect(page).to have_content("book")
            expect(page).to have_content("1")
            expect(page).to have_content("$25.00")
            expect(page).to have_content("pending")
          end

          within "#invoice_item-#{@invoice_item_2.id}" do
            expect(page).to have_content("belt")
            expect(page).to have_content("2")
            expect(page).to have_content("$10.00")
            expect(page).to have_content("packaged")
          end

          visit merchant_invoice_path(@merchant_2, @invoice_2)

          within "#invoice_item-#{@invoice_item_4.id}" do
            expect(page).to have_content("soda")
            expect(page).to have_content("2")
            expect(page).to have_content("$10.00")
            expect(page).to have_content("packaged")
          end
        end
      end

      describe "User Story 17 - Total Revenue" do
        it "displays the total revenue generated from all items" do
          expect(page).to have_content("Total Revenue: 10500")

          visit merchant_invoice_path(@merchant_2, @invoice_2)

          expect(page).to have_content("Total Revenue: 2000")
        end
      end

      describe "User Story 18 - Update Item Status" do
        it "displays a select field with current status selected for Items" do
          within "#invoice_item-#{@invoice_item_1.id}" do
            expect(page).to have_select("Status", with_options: ["pending", "packaged", "shipped"])
            expect(page.find_field("Status").value).to eq("pending")
          end

          within "#invoice_item-#{@invoice_item_2.id}" do
            expect(page).to have_select("Status", with_options: ["pending", "packaged", "shipped"])
            expect(page.find_field("Status").value).to eq("packaged")
          end
        end

        it "updates each Item's status when I click Submit" do
          within "#invoice_item-#{@invoice_item_1.id}" do
            expect(page.find_field("Status").value).to_not eq("shipped")

            select "shipped", from: "Status"
            click_button

            expect(page.current_path).to eq(merchant_invoice_path(@merchant_1.id, @invoice_1))
            expect(page.find_field("Status").value).to eq("shipped")
          end

          within "#invoice_item-#{@invoice_item_2.id}" do
            expect(page.find_field("Status").value).to_not eq("pending")

            select "pending", from: "Status"
            click_button

            expect(page.current_path).to eq(merchant_invoice_path(@merchant_1.id, @invoice_1))
            expect(page.find_field("Status").value).to eq("pending")
          end
        end
      end
    end

    describe "tests for final project" do
      describe "total revenue and discounted revenue" do
        let(:merchant_1) {create(:merchant)}
        let(:item_1) {create(:item, merchant: merchant_1)}
        let(:item_2) {create(:item, merchant: merchant_1)}
        let(:invoice_1) {create(:invoice)}

        it "displays total revenue without discounts" do
          invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 2, unit_price: 1000, status: 0)
          invoice_item_2 = InvoiceItem.create!(item: item_2, invoice: invoice_1, quantity: 2, unit_price: 1000, status: 0)

          visit merchant_invoice_path(merchant_1, invoice_1)
          expect(page).to have_content("Total Revenue: 4000")
        end

        it "displays total discounted revenue" do
          invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 20, unit_price: 1000, status: 0)  # 10% off
          invoice_item_2 = InvoiceItem.create!(item: item_2, invoice: invoice_1, quantity: 10, unit_price: 1000, status: 0)
          bulk_discount_1 = merchant_1.bulk_discounts.create!(discount: 10, quantity: 20)
          
          visit merchant_invoice_path(merchant_1, invoice_1)
          expect(page).to have_content("Discounted Revenue: 28000")
        end
      end

      it "displays link to applied discount's show page" do
        
      end
    end
  end
end
