class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :name
      t.integer :amount
      t.decimal :price, precision: 8, scale: 2

      t.timestamps
    end
  end
end
