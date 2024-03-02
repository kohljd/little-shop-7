require "rails_helper"

RSpec.describe Item, type: :model do
  describe "validations" do
    it { should validate_presence_of :name}
    it { should validate_presence_of :description}

    it { should validate_presence_of :unit_price}
    it { should validate_numericality_of :unit_price}

    it { should validate_presence_of :status}
    it { should define_enum_for(:status).with_values("Enabled" => 0, "Disabled" => 1)}
  end

  describe "relationships" do
    it {should belong_to :merchant}
    it {should have_many :invoice_items}
    it {should have_many(:invoices).through(:invoice_items)}
  end

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

    @invoice_item_1 = InvoiceItem.create!(quantity: 2, unit_price: 10000, status: 1, item_id: @item_1.id, invoice_id: @invoice_1.id)
    @invoice_item_2 =InvoiceItem.create!(quantity: 2, unit_price: 10000, status: 1, item_id: @item_2.id, invoice_id: @invoice_2.id)
    @invoice_item_3 =InvoiceItem.create!(quantity: 2, unit_price: 10000, status: 1, item_id: @item_3.id, invoice_id: @invoice_3.id)
    @invoice_item_4 =InvoiceItem.create!(quantity: 2, unit_price: 10000, status: 0, item_id: @item_4.id, invoice_id: @invoice_4.id)
    @invoice_item_5 =InvoiceItem.create!(quantity: 2, unit_price: 10000, status: 0, item_id: @item_1.id, invoice_id: @invoice_5.id)
    @invoice_item_6 =InvoiceItem.create!(quantity: 2, unit_price: 10000, status: 1, item_id: @item_1.id, invoice_id: @invoice_5.id)
  end


  describe "instance methods" do
    describe "date_an_invoice_was_created" do
      it "returns the created_at date for a particular invoice of an item" do
        expect(@item_1.date_an_invoice_was_created(@invoice_1.id)).to eq("Thursday, September 30, 2021")
        expect(@item_2.date_an_invoice_was_created(@invoice_2.id)).to eq("Saturday, October 12, 2019")

        item = create(:item)
        item_2 = create(:item)

        expect(item.date_an_invoice_was_created(@invoice_2.id)).to eq("No Invoice for this Item")
        expect(item_2.date_an_invoice_was_created(@invoice_2.id)).to eq("No Invoice for this Item")
      end
    end
  end
end
