class AddAvailableToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :available, :boolean, default: true, null: false
  end
end
