class AddBookingLinkToSailing < ActiveRecord::Migration[7.1]
  def change
    add_column :sailings, :booking_link, :string
  end
end
