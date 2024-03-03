class BulkDiscountsController < ApplicationController
  def index
    @bulk_discounts = BulkDiscount.all
  end
end