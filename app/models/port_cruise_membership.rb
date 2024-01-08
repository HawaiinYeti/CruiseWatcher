class PortCruiseMembership < ApplicationRecord
  belongs_to :port
  belongs_to :cruise
  validates :port_id, uniqueness: { scope: :cruise_id }
end
