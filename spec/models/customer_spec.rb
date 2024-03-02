require "rails_helper"

RSpec.describe Customer, type: :model do
  describe "validations "do
    it { should validate_presence_of :first_name}
    it { should validate_presence_of :last_name}
  end

  describe "relationships" do
    it {should have_many :invoices}
    it {should have_many(:transactions).through(:invoices)}
  end

  before do
    @customer_1 = Customer.create!(first_name: "First", last_name: "Customer")
    @customer_2 = Customer.create!(first_name: "Second", last_name: "Customer")
    @customer_3 = Customer.create!(first_name: "Third", last_name: "Customer")
    @customer_4 = Customer.create!(first_name: "Fourth", last_name: "Customer")
    @customer_5 = Customer.create!(first_name: "Fifth", last_name: "Customer")

    @invoice_1 = Invoice.create!(customer: @customer_1, status: 0)
    @invoice_2 = Invoice.create!(customer: @customer_2, status: 0)
    @invoice_3 = Invoice.create!(customer: @customer_3, status: 0)
    @invoice_4 = Invoice.create!(customer: @customer_4, status: 0)
    @invoice_5 = Invoice.create!(customer: @customer_5, status: 0)

    Transaction.create!(invoice: @invoice_1, result: "success", credit_card_number: 5, credit_card_expiration_date: 7)
    Transaction.create!(invoice: @invoice_2, result: "success", credit_card_number: 5, credit_card_expiration_date: 7)
    Transaction.create!(invoice: @invoice_3, result: "success", credit_card_number: 5, credit_card_expiration_date: 7)
    Transaction.create!(invoice: @invoice_4, result: "success", credit_card_number: 5, credit_card_expiration_date: 7)
    Transaction.create!(invoice: @invoice_5, result: "success", credit_card_number: 5, credit_card_expiration_date: 7)
  end

  describe "class methods" do 
    describe "self.top_customers" do 
      it "Takes the top 5 costumers with successful transactions" do 
        expect(Customer.top_customers).to eq([@customer_1, @customer_2, @customer_3, @customer_4, @customer_5])  
      end 
    end 
  end 

  describe "instance methods" do 
    it "lists successful transaction count" do
      expect(@customer_1.transaction_count).to eq(1)
    end

    it "display customer's full name" do
      expect(@customer_1.full_name).to eq("First Customer")
    end
  end 
end

require "rails_helper"

RSpec.describe , type: :model do
  describe "validations" do
    it { should validate_presence_of :}
    it { should validate_presence_of :}
  end

  describe "relationships" do
    it {should belong_to :}
    it {should have_many :}
    it {should have_many(:).through(:)}
  end
end