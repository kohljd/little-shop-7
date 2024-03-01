class CreateBulkDiscounts < ActiveRecord::Migration[7.1]
  def change
    create_table :bulk_discounts do |t|
      t.string :percentage
      t.integer :min_amount
      t.references :merchant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
