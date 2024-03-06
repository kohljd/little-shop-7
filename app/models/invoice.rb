class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :invoice_items
  has_many :transactions
  has_many :items, through: :invoice_items

  validates :status, presence: true

  enum status: {"In Progress" => 0, "Completed" => 1, "Cancelled" => 2}

  def self.incomplete_invoices
    Invoice.joins(:invoice_items)
      .where("invoice_items.status != 2")
      .group(:id)
      .order(:created_at)
  end

  def format_date_created
    self.created_at.strftime("%A, %B %d, %Y")
  end

  def total_revenue
    invoice_items.sum("invoice_items.quantity * invoice_items.unit_price")
  end

  def total_invoice_revenue(merchant)
    invoice_items.joins(:item)
      .where("items.merchant_id = #{merchant.id}")
      .sum("invoice_items.quantity * invoice_items.unit_price")
  end

  def total_discounted_revenue(invoice, merchant)
    InvoiceItem.find_by_sql(
      "SELECT SUM(invoice_items.quantity * invoice_items.unit_price) AS undiscounted_total_revenue,
        CAST(SUM((1 - ((bulk_discounts.discount + 0.0) / 100)) * (invoice_items.quantity * invoice_items.unit_price)) AS INTEGER) AS discounted_total_revenue,
        CAST(SUM(((bulk_discounts.discount + 0.0)/100) * invoice_items.quantity * invoice_items.unit_price) AS INTEGER) AS amount_customer_saved,
        bulk_discounts.id AS discount_applied

      FROM invoice_items
      JOIN items ON items.id = invoice_items.item_id
      JOIN merchants ON merchants.id = items.merchant_id
      JOIN bulk_discounts ON bulk_discounts.merchant_id = merchants.id

      WHERE invoice_items.invoice_id = #{invoice.id}
      AND items.merchant_id = #{merchant.id}
      AND bulk_discounts.merchant_id = #{merchant.id}
      AND invoice_items.quantity >= bulk_discounts.quantity
      AND bulk_discounts.discount = (
        SELECT MAX(discount) FROM bulk_discounts as inner_discounts
        WHERE invoice_items.quantity >= inner_discounts.quantity
        AND bulk_discounts.merchant_id = inner_discounts.merchant_id
        GROUP BY inner_discounts.discount
        ORDER BY inner_discounts.discount DESC LIMIT 1
      )
      GROUP BY invoice_items.item_id, bulk_discounts.id"
    )
  end
end