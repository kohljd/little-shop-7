class BulkDiscount < ApplicationRecord
  belongs_to :merchant
 
  validates :discount, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
