class BulkDiscount < ApplicationRecord
  belongs_to :merchant

  validates  :percentage, presence: true
  validates  :min_amount, presence: true
end