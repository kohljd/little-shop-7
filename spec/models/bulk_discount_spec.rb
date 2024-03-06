require "rails_helper"

RSpec.describe BulkDiscount, type: :model do
  describe "validations "do
    it { should validate_presence_of :percentage}
    it { should validate_presence_of :min_amount}
  end

  describe "relationships" do
    it {should belong_to :merchant}
  end
end