require "rails_helper"

RSpec.describe "Admin Invoices Show", type: :feature do
  describe "As a admin" do
    describe "previous tests" do
      before do
        @merchant_1 = create(:merchant)

        @item_1 = create(:item, name: "shoes", merchant: @merchant_1)
        @item_2 = create(:item, name: "book", merchant: @merchant_1)
        @item_3 = create(:item, name: "lamp", merchant: @merchant_1)

        @customer_1 = Customer.create!(first_name: "Lance", last_name: "B")
        @customer_2 = Customer.create!(first_name: "Jess", last_name: "K")

        @invoice_1 = @customer_1.invoices.create!(status: 1, created_at: "2011-09-13")
        @invoice_2 = @customer_2.invoices.create!(status: 2, created_at: "2022-03-08")

        @invoice_item_1 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_1.id, quantity: 1, unit_price: 2500, status: 0) # pending
        @invoice_item_2 = InvoiceItem.create!(item_id: @item_2.id, invoice_id: @invoice_1.id, quantity: 2, unit_price: 1000, status: 1) # packaged
        @invoice_item_3 = InvoiceItem.create!(item_id: @item_3.id, invoice_id: @invoice_1.id, quantity: 3, unit_price: 5000, status: 2) # shipped

        visit admin_invoice_path(@invoice_1)
      end

      describe "User Story 33 - Admin Invoice Show page" do
        it "list invoice attributes" do
          expect(page).to have_content(@invoice_1.id)
          expect(page.find_field("Status").value).to eq("Completed")
          expect(page).to have_content("Tuesday, September 13, 2011")
          expect(page).to_not have_content(@invoice_2.id)
          expect(page.find_field("Status").value).to_not eq("Cancelled")
          expect(page).to_not have_content("Tuesday, March 08, 2022")
        end

        it "has customers first and last name" do
          expect(page).to have_content("Lance B")
          expect(page).to_not have_content("Jess K")
        end
      end

      describe "User Story 34 - Invoice Item Information" do
        it "lists invoice's items and their info" do
          within "#invoice_item-#{@invoice_item_1.id}" do
            expect(page).to have_content("shoes")
            expect(page).to have_content("1")
            expect(page).to have_content("$25.00")
            expect(page).to have_content("pending")
          end

          within "#invoice_item-#{@invoice_item_2.id}" do
            expect(page).to have_content("book")
            expect(page).to have_content("2")
            expect(page).to have_content("$10.00")
            expect(page).to have_content("packaged")
          end

          within "#invoice_item-#{@invoice_item_3.id}" do
            expect(page).to have_content("lamp")
            expect(page).to have_content("3")
            expect(page).to have_content("$50.00")
            expect(page).to have_content("shipped")
          end
        end
      end

      #skipped - method updated and tested w/final project tests
      # describe "User Story 35 - Invoice's Total Revenue" do
      #   xit "displays total revenue to be made from this invoice" do
      #     expect(page).to have_content("Total Revenue: $195.00")
      #   end
      # end

      describe "User Story 36 - Update Invoice Status" do
        it "displays current status in a 'select' field" do
          expect(page).to have_select("Status", with_options: ["In Progress", "Completed", "Cancelled"])
          expect(page.find_field("Status").value).to eq("Completed")
        end

        it "updates invoice status and reloads show page" do
          select "In Progress", from: "Status"
          click_button "Update Invoice"

          expect(current_path).to eq(admin_invoice_path(@invoice_1))
          expect(page.find_field("Status").value).to eq("In Progress")
        end
      end
    end

    describe "total and discounted revenue" do
      let!(:merchant_3) {create(:merchant)}
      let!(:merchant_4) {create(:merchant)}
  
      let!(:item_4) {create(:item, merchant: merchant_3)}
      let!(:item_5) {create(:item, merchant: merchant_3)}
      let!(:item_6) {create(:item, merchant: merchant_3)}
      let!(:item_7) {create(:item, merchant: merchant_4)}
      let!(:item_8) {create(:item, merchant: merchant_4)}

      let!(:invoice_3) {create(:invoice)}
      let!(:invoice_item_1) {InvoiceItem.create!(item: item_4, invoice: invoice_3, quantity: 20, unit_price: 1000, status: 0)} # merchant 1 item, 10% off
      let!(:invoice_item_2) {InvoiceItem.create!(item: item_7, invoice: invoice_3, quantity: 20, unit_price: 1000, status: 0)} # merchant 2 item, 20% off
      
      let!(:bulk_discount_1) {merchant_3.bulk_discounts.create!(discount: 10, quantity: 20)}
      let!(:bulk_discount_2) {merchant_3.bulk_discounts.create!(discount: 50, quantity: 30)}
      let!(:bulk_discount_3) {merchant_4.bulk_discounts.create!(discount: 20, quantity: 15)}
      let!(:bulk_discount_4) {merchant_4.bulk_discounts.create!(discount: 15, quantity: 15)}

      it "displays total revenue without discounts" do
        visit admin_invoice_path(invoice_3)
        expect(page).to have_content("Subtotal: 40000")
      end

      it "displays total of discounts applied" do
        visit admin_invoice_path(invoice_3)
        expect(page).to have_content("Total Discounts: 6000")
      end

      it "discplays total revenue after discounts applied" do
        visit admin_invoice_path(invoice_3)
        expect(page).to have_content("Total Revenue: 34000")
      end
    end
  end
end