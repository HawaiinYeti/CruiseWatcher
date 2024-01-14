class AddPriceDrop24hrToRoom < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :price_change_24hr, :decimal, default: 0.0, null: false
  end
end
