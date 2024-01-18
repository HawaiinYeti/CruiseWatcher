class Cruise < ApplicationRecord
  belongs_to :ship
  has_many :sailings, dependent: :destroy
  has_many :port_cruise_memberships, dependent: :destroy
  has_many :ports, through: :port_cruise_memberships

  def create_port_memberships(ports)
    objects = ports.map do |port|
      obj = Port.find_by(code: port[:ports].first[:port][:code])
      PortCruiseMembership.find_or_initialize_by(cruise_id: self.id, port_id: obj.id, day: port[:number])
    end

    self.port_cruise_memberships = objects
  end
end
