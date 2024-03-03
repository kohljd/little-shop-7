require "rails_helper"

RSpec.describe "Merchant Dashboard" do
  before do
    @merchant_1 = Merchant.create!(name: "Barry")

    @yain = Customer.create!(first_name: "Yain", last_name: "Porter")
    @joey = Customer.create!(first_name: "Joey", last_name: "R")
    @jess = Customer.create!(first_name: "Jess", last_name: "K")
    @lance = Customer.create!(first_name: "Lance", last_name: "B")
    @abdul = Customer.create!(first_name: "Abdul", last_name: "R")

    @invoice_1 = Invoice.create!(customer_id: @yain.id, status: 1, created_at: "2021-09-30")
    @invoice_2 = Invoice.create!(customer_id: @joey.id, status: 1, created_at: "2019-10-12")
    @invoice_3 = Invoice.create!(customer_id: @jess.id, status: 1, created_at: "2022-01-11")
    @invoice_4 = Invoice.create!(customer_id: @lance.id, status: 1)
    @invoice_5 = Invoice.create!(customer_id: @abdul.id, status: 1)

    create_list(:transaction, 20, invoice_id: @invoice_5.id)
    create_list(:transaction, 15, invoice_id: @invoice_2.id)
    create_list(:transaction, 10, invoice_id: @invoice_1.id)
    create_list(:transaction, 7, invoice_id: @invoice_3.id)
    create_list(:transaction, 5, invoice_id: @invoice_4.id)

    @item_1 = create(:item, name: "book", merchant: @merchant_1)
    @item_2 = create(:item, name: "belt", merchant: @merchant_1)
    @item_3 = create(:item, name: "shoes", merchant: @merchant_1)
    @item_4 = create(:item, name: "paint", merchant: @merchant_1)

    create(:invoice_item, status: 1, invoice_id: @invoice_1.id, item_id: @item_1.id) #packaged
    create(:invoice_item, status: 1, invoice_id: @invoice_2.id, item_id: @item_2.id) #packaged
    create(:invoice_item, status: 1, invoice_id: @invoice_3.id, item_id: @item_3.id) #packaged
    create(:invoice_item, status: 0, invoice_id: @invoice_4.id, item_id: @item_4.id) #pending
    create(:invoice_item, status: 0, invoice_id: @invoice_5.id, item_id: @item_1.id) #pending

    # visit "/merchants/#{@merchant_1.id}/dashboard"
    visit merchant_dashboard_index_path(@merchant_1.id)
  end

  describe "User Story 1 - Merchant Dashboard" do
    it "displays merchant name" do
      expect(page).to have_content("Barry's Dashboard")
    end
  end

  describe "User Story 2 - Merchant Dashboard Links" do
    it "has links to Merchant's items index and invoices index" do
      expect(page).to have_link("Barry's Items")

      click_link("Barry's Items")
      expect(page.current_path).to eq(merchant_items_path(@merchant_1))

      visit "/merchants/#{@merchant_1.id}/dashboard"
      expect(page).to have_link("Barry's Invoices")

      click_link("Barry's Invoices")
      expect(page.current_path).to eq(merchant_invoices_path(@merchant_1))
    end
  end

  describe "User Story 3 - Top 5 Customers" do
    it "displays names of the top five customers with successful transactions" do
      within "#top-five-customers" do
        expect("Abdul").to appear_before("Joey")
        expect("Joey").to appear_before("Yain")
        expect("Yain").to appear_before("Jess")
        expect("Jess").to appear_before("Lance")
      end
    end
    
    it "displays the number of successful transactions next to each customer" do
      expect(page).to have_content("Customer Name: Abdul R Successful Transactions: 20")
      expect(page).to have_content("Customer Name: Joey R Successful Transactions: 15")
      expect(page).to have_content("Customer Name: Yain Porter Successful Transactions: 10")
      expect(page).to have_content("Customer Name: Jess K Successful Transactions: 7")
      expect(page).to have_content("Customer Name: Lance B Successful Transactions: 5")
    end
  end

  describe "User Story 4 - Merchant Dashboard Items Ready to Ship" do
    it "displays items that are ready to ship" do
      within '#items-ready-to-ship' do
        expect(page).to have_content("Items Ready to Ship:")
      end
      within "#item-#{@item_1.id}" do
        expect(page).to have_content("book")
        expect(page).to have_link("#{@invoice_1.id}")
      end

      within "#item-#{@item_2.id}" do
        expect(page).to have_content("belt")
        expect(page).to have_link("#{@invoice_2.id}")
      end

      within "#item-#{@item_3.id}" do
        expect(page).to have_content("shoes")
        expect(page).to have_link("#{@invoice_3.id}")
      end
    end

    it "takes user to merchants invoices show page" do
      click_on "#{@invoice_1.id}"
      expect(current_path).to eq(merchant_invoice_path(@merchant_1, @invoice_1.id))

      visit merchant_dashboard_index_path(@merchant_1.id)
      click_on "#{@invoice_2.id}"
      expect(current_path).to eq(merchant_invoice_path(@merchant_1, @invoice_2.id))

      visit merchant_dashboard_index_path(@merchant_1.id)
      click_on "#{@invoice_3.id}"
      expect(current_path).to eq(merchant_invoice_path(@merchant_1, @invoice_3.id))
    end
  end

  describe "User Story 5 - Merchant Dashboard Invoices sorted by least recent" do
    it "displays the date an invoice was created for an item" do
      within "#item-#{@item_1.id}" do
        expect(page).to have_content("book - Invoice ##{@invoice_1.id} - Thursday, September 30, 2021")
      end

      within "#item-#{@item_2.id}" do
        expect(page).to have_content("belt - Invoice ##{@invoice_2.id} - Saturday, October 12, 2019")
      end

      within "#item-#{@item_3.id}" do
        expect(page).to have_content("shoes - Invoice ##{@invoice_3.id} - Tuesday, January 11, 2022")
      end
      visit merchant_dashboard_index_path(@merchant_1.id)

      expect(@item_2.date_an_invoice_was_created(@invoice_2.id)).to appear_before(@item_1.date_an_invoice_was_created(@invoice_1.id))
      expect(@item_1.date_an_invoice_was_created(@invoice_1.id)).to appear_before(@item_3.date_an_invoice_was_created(@invoice_3.id))
    end
  end

  describe "User Story 1 - Merchant Bulk Discounts Index" do
    before do
      @discount_1 = BulkDiscount.create(percentage: "20%", min_amount: 5, merchant_id: 1)
    end

    it "has a link to see all bulk discounts" do
      visit merchant_dashboard_index_path(@merchant_1.id)

      expect(page).to have_link("all my discounts")
      click_on "all my discounts"

      expect(current_path).to eq(bulk_discounts_path) #index
    end
  end
end
