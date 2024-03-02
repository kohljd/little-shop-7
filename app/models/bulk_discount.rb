class BulkDiscount < ApplicationRecord
  belongs_to :merchant
 
  validates :discount, presence: true, numericality: true
  validates :quantity, presence: true, numericality: true
end
