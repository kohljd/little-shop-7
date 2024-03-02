require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe "validations" do
    it { should validate_presence_of :name}
    it { should define_enum_for(:status).with_values(enabled: 0, disabled: 1)}
  end

  describe "relationships" do
    it {should have_many :bulk_discounts}
    it {should have_many :items}
    it {should have_many(:invoice_items).through(:items)}
    it {should have_many(:invoices).through(:invoice_items)}
    it {should have_many(:transactions).through(:invoices)}
    it {should have_many(:customers).through(:invoices)}
  end

  describe "class methods" do
    before do
      @merchant_1 = Merchant.create!(name: "Barry", status: 1)
      @merchant_2 = Merchant.create!(name: "Sally", status: 0)
      @merchant_3 = Merchant.create!(name: "Rayla", status: 1)
      @merchant_4 = Merchant.create!(name: "Beans", status: 1)
      @merchant_5 = Merchant.create!(name: "Greens", status: 1)
      @merchant_6 = Merchant.create!(name: "Potatoes", status: 0)
      @merchant_7 = Merchant.create!(name: "Chicken", status: 1)
      @merchant_8 = Merchant.create!(name: "Lamb", status: 1)
      @merchant_9 = Merchant.create!(name: "You Name IT!!!!", status: 1)

      @customer_1 = create(:customer)

      @item_4 = create(:item, merchant: @merchant_4)
      @item_5 = create(:item, merchant: @merchant_5)
      @item_6 = create(:item, merchant: @merchant_6)
      @item_7 = create(:item, merchant: @merchant_7)
      @item_8 = create(:item, merchant: @merchant_8)
      @item_9 = create(:item, merchant: @merchant_9)

      @invoice_1 = create(:invoice, customer: @customer_1)
      @invoice_2 = create(:invoice, customer: @customer_1)
      @invoice_3 = create(:invoice, customer: @customer_1)
      @invoice_4 = create(:invoice, customer: @customer_1)
      @invoice_5 = create(:invoice, customer: @customer_1)
      @invoice_6 = create(:invoice, customer: @customer_1)
      @invoice_7 = create(:invoice, customer: @customer_1)
      @invoice_8 = create(:invoice, customer: @customer_1)
      @invoice_9 = create(:invoice, customer: @customer_1)
      @invoice_10 = create(:invoice, customer: @customer_1)

      @transaction_1 = create(:transaction, invoice: @invoice_1, result: "success")
      @transaction_2 = create(:transaction, invoice: @invoice_2, result: "success")
      @transaction_3 = create(:transaction, invoice: @invoice_3, result: "success")
      @transaction_4 = create(:transaction, invoice: @invoice_4, result: "success")
      @transaction_5 = create(:transaction, invoice: @invoice_5, result: "success")
      @transaction_6 = create(:transaction, invoice: @invoice_6, result: "success")
      @transaction_7 = create(:transaction, invoice: @invoice_7, result: "success")
      @transaction_8 = create(:transaction, invoice: @invoice_8, result: "failed")
      @transaction_9 = create(:transaction, invoice: @invoice_9, result: "failed")
      @transaction_10 = create(:transaction, invoice: @invoice_10, result: "failed")

      @invoice_item_1 = create(:invoice_item, item: @item_4, invoice: @invoice_1, quantity: 1, unit_price: 1000)
      @invoice_item_2 = create(:invoice_item, item: @item_4, invoice: @invoice_2, quantity: 2, unit_price: 1500)
      @invoice_item_3 = create(:invoice_item, item: @item_5, invoice: @invoice_3, quantity: 3, unit_price: 2000)
      @invoice_item_4 = create(:invoice_item, item: @item_6, invoice: @invoice_4, quantity: 4, unit_price: 2500)
      @invoice_item_5 = create(:invoice_item, item: @item_7, invoice: @invoice_5, quantity: 5, unit_price: 3000)
      @invoice_item_6 = create(:invoice_item, item: @item_8, invoice: @invoice_6, quantity: 1, unit_price: 3500)
      @invoice_item_7 = create(:invoice_item, item: @item_9, invoice: @invoice_7, quantity: 2, unit_price: 4000)
      @invoice_item_8 = create(:invoice_item, item: @item_7, invoice: @invoice_8, quantity: 3, unit_price: 4500)
      @invoice_item_9 = create(:invoice_item, item: @item_8, invoice: @invoice_9, quantity: 4, unit_price: 5000)
      @invoice_item_10 = create(:invoice_item, item: @item_9, invoice: @invoice_10, quantity: 5, unit_price: 5500)
    end

    describe ".top_five_merchants" do
      it "list top 5 merchants from highest to lowest total revenue" do
        expect(Merchant.top_five_merchants).to eq([@merchant_7, @merchant_6, @merchant_9, @merchant_5, @merchant_4])
      end
    end

    describe "#format_total_revenue" do
      it "formats merchant's total revenue" do
        merchant = Merchant.top_five_merchants.first
        expect(merchant.format_total_revenue).to eq("$150.00")
      end
    end
  end

  describe "instance methods" do
    before do
      @merchant_1 = create(:merchant)

      @customer_1 = create(:customer)
      @customer_2 = create(:customer)
      @customer_3 = create(:customer)
      @customer_4 = create(:customer)
      @customer_5 = create(:customer)
      @customer_6 = create(:customer)

      @invoice_1 = create(:invoice, customer: @customer_1)
      @invoice_2 = create(:invoice, customer: @customer_2)
      @invoice_3 = create(:invoice, customer: @customer_3)
      @invoice_4 = create(:invoice, customer: @customer_4)
      @invoice_5 = create(:invoice, customer: @customer_5)
      @invoice_6 = create(:invoice, customer: @customer_6)

      @transactions_1 = create(:transaction, invoice: @invoice_1)
      @transactions_2 = create(:transaction, invoice: @invoice_2)
      @transactions_3 = create(:transaction, invoice: @invoice_3)
      @transactions_4 = create(:transaction, invoice: @invoice_4)
      @transactions_5 = create(:transaction, invoice: @invoice_5)
      @transactions_6 = create(:transaction, invoice: @invoice_6)

      @item_1 = create(:item, merchant: @merchant_1)
      @item_2 = create(:item, name: "belt", merchant: @merchant_1)
      @item_3 = create(:item, name: "shoes", merchant: @merchant_1)
      @item_4 = create(:item, name: "paint", merchant: @merchant_1)

      create(:invoice_item, status: 0, invoice_id: @invoice_1.id, item_id: @item_1.id)
      create(:invoice_item, status: 1, invoice_id: @invoice_2.id, item_id: @item_2.id)
      create(:invoice_item, status: 1, invoice_id: @invoice_3.id, item_id: @item_3.id)
      create(:invoice_item, status: 0, invoice_id: @invoice_4.id, item_id: @item_4.id)
      create(:invoice_item, status: 0, invoice_id: @invoice_5.id, item_id: @item_1.id)
      create(:invoice_item, status: 0, invoice_id: @invoice_6.id, item_id: @item_1.id)
      create(:invoice_item, status: 0, invoice_id: @invoice_6.id, item_id: @item_1.id)
      create(:invoice_item, status: 0, invoice_id: @invoice_6.id, item_id: @item_1.id)
      create(:invoice_item, status: 0, invoice_id: @invoice_6.id, item_id: @item_1.id)
      create(:invoice_item, status: 0, invoice_id: @invoice_6.id, item_id: @item_1.id)
      create(:invoice_item, status: 0, invoice_id: @invoice_6.id, item_id: @item_1.id)
    end

    describe "#top_five_customers" do
      it "should return the top five customers with the most successful transactions" do
        customers = [@customer_1, @customer_2, @customer_3, @customer_4, @customer_5]

        top_five_customers = @merchant_1.top_five_customers.map { |customer| Customer.find(customer.id) }

        expect(top_five_customers).to eq(customers)
      end
    end

    describe "#items_ready_to_ship" do
      it "Only selects items that have an invoice_item status as packaged" do
        expect(@merchant_1.items_ready_to_ship).to eq([@item_2, @item_3])
        expect(@merchant_1.items_ready_to_ship).not_to eq([@item_1, @item_4])
      end
    end

    describe "#top_sales_day" do
      it "returns day of highest sales revenue" do
        merchant_2 = create(:merchant)
        item_5 = create(:item, merchant: merchant_2)
        invoice_7 = create(:invoice, created_at: "2024-01-23")
        invoice_8 = create(:invoice, created_at: "2013-11-10")
        create(:transaction, invoice: invoice_7)
        create(:transaction, invoice: invoice_8)
        invoice_item_1 = create(:invoice_item, item: item_5, invoice: invoice_7, quantity: 1, unit_price: 1000)
        invoice_item_2 = create(:invoice_item, item: item_5, invoice: invoice_8, quantity: 2, unit_price: 1500)

        merchant_3 = create(:merchant)
        item_6 = create(:item, merchant: merchant_3)
        invoice_9 = create(:invoice, created_at: "2022-03-08")
        invoice_10 = create(:invoice, created_at: "2023-05-19")
        create(:transaction, invoice: invoice_9)
        create(:transaction, invoice: invoice_10)
        invoice_item_3 = create(:invoice_item, item: item_6, invoice: invoice_9, quantity: 3, unit_price: 2000)
        invoice_item_4 = create(:invoice_item, item: item_6, invoice: invoice_10, quantity: 4, unit_price: 2500)

        expect(merchant_2.top_sales_day).to eq("11/10/2013")
        expect(merchant_3.top_sales_day).to eq("5/19/2023")
      end
    end

    before do
      @barry = Merchant.create!(name: "@Barry")
      @lance = Customer.create!(first_name: "Lance", last_name: "Butler")

      @book = @barry.items.create!(name: "Book", description: "Good book", unit_price: 1500)
      @shoes = @barry.items.create!(name: "Shoes", description: "Good shoes", unit_price: 5000)
      @belt = @barry.items.create!(name: "Belt", description: "Good belt", unit_price: 5000)
      @hat = @barry.items.create!(name: "Hat", description: "Good hat", unit_price: 5000)
      @sunglasses = @barry.items.create!(name: "Sunglasses", description: "Good sunglasses", unit_price: 5000)
      @shirt = @barry.items.create!(name: "Shirt", description: "Good shirt", unit_price: 5000)
      @pants = @barry.items.create!(name: "Pants", description: "Good pants", unit_price: 5000)

      lance_invoice_1 = Invoice.create!(customer_id: @lance.id, status: 0, created_at: "2015-05-05")
      lance_invoice_2 = Invoice.create!(customer_id: @lance.id, status: 0, created_at: "2014-04-04")
      lance_invoice_3 = Invoice.create!(customer_id: @lance.id, status: 0, created_at: "2013-03-03")
      lance_invoice_4 = Invoice.create!(customer_id: @lance.id, status: 0, created_at: "2012-02-02")

      #Invoice 1
      InvoiceItem.create!(item_id: @book.id, invoice_id: lance_invoice_1.id, quantity: 4, status: 1, unit_price: 1000)
      InvoiceItem.create!(item_id: @shoes.id, invoice_id: lance_invoice_1.id, quantity: 2, status: 1, unit_price: 2500)
      InvoiceItem.create!(item_id: @hat.id, invoice_id: lance_invoice_1.id, quantity: 2, status: 1, unit_price: 2500)
      InvoiceItem.create!(item_id: @belt.id, invoice_id: lance_invoice_1.id, quantity: 2, status: 1, unit_price: 2500)
      InvoiceItem.create!(item_id: @shoes.id, invoice_id: lance_invoice_1.id, quantity: 2, status: 1, unit_price: 2500)
      InvoiceItem.create!(item_id: @pants.id, invoice_id: lance_invoice_1.id, quantity: 2, status: 1, unit_price: 2500)
      InvoiceItem.create!(item_id: @sunglasses.id, invoice_id: lance_invoice_1.id, quantity: 1, status: 1, unit_price: 25000)
      # books - 4000x2 = 8000
      # belts - 5000x2 = 10000
      # shoes - 10000x2 = 20000
      # hat - 5000x2 = 10000
      # pants - 5000x2 = 10000
      # sunglasses 25000x2 = 50000
      create(:transaction, invoice: lance_invoice_1, result: "success")
      create(:transaction, invoice: lance_invoice_1, result: "failed")
      create(:transaction, invoice: lance_invoice_1, result: "success")

      #Invoice 2
      InvoiceItem.create!(item_id: @book.id, invoice_id: lance_invoice_2.id, quantity: 3, status: 1, unit_price: 1000)
      InvoiceItem.create!(item_id: @shoes.id, invoice_id: lance_invoice_2.id, quantity: 2, status: 1, unit_price: 2500)
      InvoiceItem.create!(item_id: @shirt.id, invoice_id: lance_invoice_2.id, quantity: 1, status: 1, unit_price: 2500)
      InvoiceItem.create!(item_id: @sunglasses.id, invoice_id: lance_invoice_2.id, quantity: 2, status: 1, unit_price: 2500)
      InvoiceItem.create!(item_id: @belt.id, invoice_id: lance_invoice_2.id, quantity: 2, status: 1, unit_price: 2500)
      # books - 3000x6 = 18000
      # shirts - 5000x6 = 15000
      # belts - 5000x6 = 30000
      # shoes - 5000x6 = 30000
      # sunglasses - 5000x6 = 30000
      create(:transaction, invoice: lance_invoice_2, result: "success")
      create(:transaction, invoice: lance_invoice_2, result: "success")
      create(:transaction, invoice: lance_invoice_2, result: "success")
      create(:transaction, invoice: lance_invoice_2, result: "success")
      create(:transaction, invoice: lance_invoice_2, result: "success")
      create(:transaction, invoice: lance_invoice_2, result: "success")

      #Invoice 3
      InvoiceItem.create!(item_id: @book.id, invoice_id: lance_invoice_3.id, quantity: 1, status: 1, unit_price: 10000)
      InvoiceItem.create!(item_id: @belt.id, invoice_id: lance_invoice_3.id, quantity: 2, status: 1, unit_price: 25000)
      InvoiceItem.create!(item_id: @shirt.id, invoice_id: lance_invoice_3.id, quantity: 2, status: 1, unit_price: 25000)
      InvoiceItem.create!(item_id: @shoes.id, invoice_id: lance_invoice_3.id, quantity: 2, status: 1, unit_price: 25000)
      # books - 10000x1 = 10000
      # shirts - 50000x1 = 50000
      # shoes - 50000x1 = 50000
      # belts - 50000x1 = 50000
      create(:transaction, invoice: lance_invoice_3, result: "failed")
      create(:transaction, invoice: lance_invoice_3, result: "failed")
      create(:transaction, invoice: lance_invoice_3, result: "success")

      #Invoice 4
      InvoiceItem.create!(item_id: @book.id, invoice_id: lance_invoice_4.id, quantity: 4, status: 1, unit_price: 100000000)
      InvoiceItem.create!(item_id: @shoes.id, invoice_id: lance_invoice_4.id, quantity: 2, status: 1, unit_price: 25000000)
      create(:transaction, invoice: lance_invoice_4, result: "failed")
      create(:transaction, invoice: lance_invoice_4, result: "failed")
      create(:transaction, invoice: lance_invoice_4, result: "failed")
      create(:transaction, invoice: lance_invoice_4, result: "failed")

      # Total shoes = 100000
      # Total belt = 90000
      # total sunglasses = 80000
      # Total shirts = 65000
      # Total books = 36000
      #Invoices must have at least one succfessful transaction to be counted
    end
    
    describe "#top_5_popular_items" do
      it "only counts invoices with at least 1 successful transaction" do
        expect(@barry.top_5_popular_items).to eq([@shoes, @belt, @sunglasses, @shirt, @book])

        lance_invoice_5 = Invoice.create!(customer_id: @lance.id, status: 0, created_at: "2011-01-01")
        InvoiceItem.create!(item_id: @pants.id, invoice_id: lance_invoice_5.id, quantity: 4, status: 1, unit_price: 25000)
        InvoiceItem.create!(item_id: @belt.id, invoice_id: lance_invoice_5.id, quantity: 2, status: 1, unit_price: 5000)
        InvoiceItem.create!(item_id: @hat.id, invoice_id: lance_invoice_5.id, quantity: 3, status: 1, unit_price: 25000)
        create(:transaction, invoice: lance_invoice_5, result: "success")
        create(:transaction, invoice: lance_invoice_5, result: "success")
        # Total pants = 201000
        # Total hat = 160000
        # Total belt = 110000

        expect(@barry.top_5_popular_items).to eq([@pants, @hat, @belt, @shoes, @sunglasses])
      end
    end

    describe "#top_sales_date_for_item" do
      it "returns the date in MM/DD/YY" do
        expect(@barry.top_sales_date_for_item(@sunglasses.id)).to eq("5/5/15")
        expect(@barry.top_sales_date_for_item(@shoes)).to eq("3/3/13")
      end
    end
  end
end
