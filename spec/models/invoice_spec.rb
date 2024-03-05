require "rails_helper"

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status}
    it { should define_enum_for(:status).with_values("In Progress" => 0, "Completed" => 1, "Cancelled" => 2)}
  end

  describe "relationships" do
    it {should belong_to :customer}
    it {should have_many :invoice_items}
    it {should have_many :transactions}
    it {should have_many(:items).through(:invoice_items)}
  end

  describe "class methods" do
    before do
      @customer_1 = create(:customer)
  
      @merchant_1 = create(:merchant)
      @items = create_list(:item, 5, merchant: @merchant_1)
  
      @invoice_1 = create(:invoice, customer: @customer_1, created_at: "2015-12-09")
      @invoice_2 = create(:invoice, customer: @customer_1, created_at: "2013-11-10")
      @invoice_3 = create(:invoice, customer: @customer_1, created_at: "2011-09-17")
      @invoice_4 = create(:invoice, customer: @customer_1, created_at: "2010-12-31")
  
      @invoice_items_1 = create(:invoice_item, invoice: @invoice_1)
      @invoice_items_2 = create(:invoice_item, invoice: @invoice_2)
      @invoice_items_3 = create(:invoice_item, status: 1, invoice: @invoice_3)
      @invoice_items_4 = create(:invoice_item, status: 2, invoice: @invoice_4)
    end

    describe ".incomplete_invoices" do
      it "lists incomplete invoices" do
        expect(Invoice.incomplete_invoices).to eq([@invoice_3, @invoice_2, @invoice_1])

        invoice_5 = create(:invoice, customer: @customer_1)
        invoice_items_5 = create(:invoice_item, invoice: invoice_5)

        expect(Invoice.incomplete_invoices).to eq([@invoice_3, @invoice_2, @invoice_1, invoice_5])
      end

      it "lists incomplete invoices from oldest to newest" do
        expect(Invoice.incomplete_invoices).to eq([@invoice_3, @invoice_2, @invoice_1])

        invoice_5 = create(:invoice, customer: @customer_1, created_at: "2012-12-09")
        invoice_items_5 = create(:invoice_item, invoice: invoice_5)

        expect(Invoice.incomplete_invoices).to eq([@invoice_3, invoice_5, @invoice_2, @invoice_1])
      end
    end
  end

  describe "instance methods" do
    let(:merchant_1) {create(:merchant)}
    let(:merchant_2) {create(:merchant)}

    let(:item_1) {create(:item, merchant: merchant_1)}
    let(:item_2) {create(:item, merchant: merchant_1)}
    let(:item_3) {create(:item, merchant: merchant_1)}
    let(:item_4) {create(:item, merchant: merchant_2)}
    let(:item_5) {create(:item, merchant: merchant_2)}

    let(:customer_1) {create(:customer)}

    let(:invoice_1) {customer_1.invoices.create!(status: 1, created_at: "2015-12-09")}
    let(:invoice_2) {customer_1.invoices.create!(status: 2, created_at: "2013-11-10")}
    
    describe "#format_date_created" do
      it "formats the created_at date" do
        invoice_item_1 = InvoiceItem.create!(item_id: item_1.id, invoice_id: invoice_1.id, quantity: 1, unit_price: 2500, status: 0)
        invoice_item_2 = InvoiceItem.create!(item_id: item_2.id, invoice_id: invoice_1.id, quantity: 2, unit_price: 1000, status: 1)
        invoice_item_3 = InvoiceItem.create!(item_id: item_3.id, invoice_id: invoice_1.id, quantity: 3, unit_price: 5000, status: 2)

        expect(invoice_1.format_date_created).to eq("Wednesday, December 09, 2015")
        expect(invoice_2.format_date_created).to eq("Sunday, November 10, 2013")
      end
    end

    describe "#total_invoice_revenue" do
      describe "calculates an invoice's total revenue" do
        describe "scenarios:" do
          it "varying invoice_item statuses, 1 merchant" do
            invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 1, unit_price: 2500, status: 0)
            invoice_item_2 = InvoiceItem.create!(item: item_2, invoice: invoice_1, quantity: 2, unit_price: 1000, status: 1)
            invoice_item_3 = InvoiceItem.create!(item: item_3, invoice: invoice_1, quantity: 3, unit_price: 5000, status: 2)

            expect(invoice_1.total_revenue).to eq(19500)
          end

          it "2 merchants' items on invoice" do
            invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 1, unit_price: 2500, status: 0)
            invoice_item_2 = InvoiceItem.create!(item: item_5, invoice: invoice_1, quantity: 2, unit_price: 1000, status: 1)

            expect(invoice_1.total_revenue).to eq(4500)
          end
        end
      end
    end
    
        describe "#total_revenue(merchant)" do
          describe "merchant's total revenue for their items on an invoice" do
            it "1 merchant on invoice" do
              invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 2, unit_price: 1000, status: 0)
              invoice_item_2 = InvoiceItem.create!(item: item_2, invoice: invoice_1, quantity: 2, unit_price: 1000, status: 0)
    
              expect(invoice_1.total_revenue(merchant_1)).to eq(4000)
            end
    
            it "2 merchants' items on invoice" do
              invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 2, unit_price: 1000, status: 0)
              invoice_item_2 = InvoiceItem.create!(item: item_5, invoice: invoice_1, quantity: 2, unit_price: 1000, status: 0)
    
              expect(invoice_1.total_revenue(merchant_1)).to eq(4000)
              expect(invoice_2.total_revenue(merchant_2)).to eq(4000)
            end
          end
        end
    
    describe "#total_discounted_revenue(merchant)" do
      describe "it calculates an invoice's total discounted revenue" do
        describe "scenarios:" do
          let!(:bulk_discount_1) {merchant_1.bulk_discounts.create!(discount: 10, quantity: 20)}
          let!(:bulk_discount_2) {merchant_1.bulk_discounts.create!(discount: 50, quantity: 30)}
          let!(:bulk_discount_3) {merchant_2.bulk_discounts.create!(discount: 20, quantity: 15)}
          let!(:bulk_discount_4) {merchant_2.bulk_discounts.create!(discount: 15, quantity: 15)}

          it "no qualifying bulk discount" do
            invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 10, unit_price: 1000, status: 0)
            invoice_item_2 = InvoiceItem.create!(item: item_2, invoice: invoice_1, quantity: 10, unit_price: 1000, status: 0)

            expect(invoice_1.total_discounted_revenue(merchant_1)).to eq(20000)
          end

          it "1 item qualifies for a bulk discount" do
            invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 20, unit_price: 1000, status: 0)  # 10% off
            invoice_item_2 = InvoiceItem.create!(item: item_2, invoice: invoice_1, quantity: 10, unit_price: 1000, status: 0)

            expect(invoice_1.total_discounted_revenue(merchant_1)).to eq(28000)
          end

          it "applies the better of merchant's two discounts - 1 item meets 2 discounts' criteria" do
            invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 30, unit_price: 1000, status: 0) # meet 10% & 50% off
            invoice_item_2 = InvoiceItem.create!(item: item_2, invoice: invoice_1, quantity: 10, unit_price: 1000, status: 0)

            expect(invoice_1.total_discounted_revenue(merchant_1)).to eq(25000)
          end

          it "each item meets criteria for separate discounts" do
            invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 30, unit_price: 1000, status: 0)  # 50% off
            invoice_item_2 = InvoiceItem.create!(item: item_2, invoice: invoice_1, quantity: 20, unit_price: 1000, status: 0) # 10% off

            expect(invoice_1.total_discounted_revenue(merchant_1)).to eq(33000)
          end

          it "each item meets criteria for the same discount" do
            invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 20, unit_price: 1000, status: 0)  # 10% off
            invoice_item_2 = InvoiceItem.create!(item: item_2, invoice: invoice_1, quantity: 20, unit_price: 1000, status: 0) # 10% off

            expect(invoice_1.total_discounted_revenue(merchant_1)).to eq(36000)
          end

          it "multiple merchants' items on an invoice - no qualifying discount" do
            invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 10, unit_price: 1000, status: 0) # merchant 1 item, no discount
            invoice_item_2 = InvoiceItem.create!(item: item_4, invoice: invoice_1, quantity: 10, unit_price: 1000, status: 0) # merchant 2 item, no discount

            expect(invoice_1.total_discounted_revenue(merchant_1)).to eq(10000)
            expect(invoice_1.total_discounted_revenue(merchant_2)).to eq(10000)
          end

          it "multiple merchants' items on an invoice - 1 qualifies for discount" do
            invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 15, unit_price: 1000, status: 0) # merchant 1 item, no discount
            invoice_item_2 = InvoiceItem.create!(item: item_4, invoice: invoice_1, quantity: 15, unit_price: 1000, status: 0) # merchant 2 item, 20% off

            expect(invoice_1.total_discounted_revenue(merchant_1)).to eq(15000)
            expect(invoice_1.total_discounted_revenue(merchant_2)).to eq(12000)
          end

          it "multiple merchants' items on an invoice - both qualify for discount" do
            invoice_item_1 = InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 20, unit_price: 1000, status: 0) # merchant 1 item, 10% off
            invoice_item_2 = InvoiceItem.create!(item: item_4, invoice: invoice_1, quantity: 20, unit_price: 1000, status: 0) # merchant 2 item, 20% off

            expect(invoice_1.total_discounted_revenue(merchant_1)).to eq(18000)
            expect(invoice_1.total_discounted_revenue(merchant_2)).to eq(16000)
          end
        end
      end
    end
  end
end
