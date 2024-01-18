class AddDayToPortCruiseMembership < ActiveRecord::Migration[7.1]
  def change
    add_column :port_cruise_memberships, :day, :integer
    add_column :cruises, :nights, :integer
  end
end
