class Customer < ApplicationRecord
  has_many :invoices
  has_many :transactions, through: :invoices

  validates :first_name, presence: true
  validates :last_name, presence: true
  
  def self.top_customers 
    where("transactions.result = 0")
      .joins(:transactions)
      .group(:id)
      .order("count(transactions.result) DESC")
      .limit(5)
  end

  def transaction_count
    transactions.count
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end