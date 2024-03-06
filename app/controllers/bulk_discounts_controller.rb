class BulkDiscountsController < ApplicationController
  def index
    @bulk_discounts = BulkDiscount.all
  end

  def show ; end

  def new 
  end

  def create
    bulk_discount = BulkDiscount.create
    redirect_to bulk_discounts_path
  end

  private
  def bulk_discounts_params
    params.permit(:percentage)
    params.permit(:min_amount)
  end
end