class BulkDiscount < ApplicationRecord
  belongs_to :merchant
 
  validates :discount, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
