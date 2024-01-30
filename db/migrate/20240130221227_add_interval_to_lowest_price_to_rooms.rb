class AddIntervalToLowestPriceToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :interval_to_lowest_price, :interval
  end
end
